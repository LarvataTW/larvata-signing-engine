module Larvata
  module Signing
    module DocService
      # 確認送簽
      def commit!
        Larvata::Signing::Doc.transaction do
          self.state = "signing"
          self.committed_at = Time.current
          self.save!

          first_stage = self.stages.first
          first_stage&.state = "signing"
          first_stage&.save!

          resource_records.update_all(state: 'signing')

          # 更新原始單據狀態
          resource_records.each do |res_rec|
            _form_data = res_rec.signing_resourceable
            _form_data&.update_column("state", 'signing') if _form_data.class.defined_enums&.dig("state")&.dig("signing").present?
          end

          send_messages("signing", self.stages.first&.id)
        end
      end

      # 簽核邏輯：https://projects.larvata.tw/issues/70725
      def sign(current_user, signing_result, comment, **opt)
        return self unless validate_doc_is_signing

        srecords = signing_srecords(signing_stage, current_user)

        send(signing_result, comment, srecords, opt)

        self.reload
      end

      # 中止
      def terminate
        rejected!
        signing_stage&.terminated!
        rejection_of_resource_records(resource_records)
      end

      # 作廢簽核單
      def obsolete
        void!
        rejection_of_resource_records(resource_records)
      end

      def rejection_of_resource_records(resource_records)
        # 讓resource_records 簽核單原始單據編號資料的狀態變為「駁回」
        resource_records.update_all(state: "rejected")

        # 執行申請單據的 return_method
        resource_records.each do |res_rec|
          res_rec.signing_resourceable&.send(resource&.returned_method)
        end
      end

      private

      # 目前需要簽核的階段
      def signing_stage
        Larvata::Signing::Stage.signing.includes(:doc, :srecords).where(larvata_signing_doc_id: id).first
      end

      # 抓取 current_user 以及其代理的人
      def signer_ids(current_user)
        Larvata::Signing::Agent.agents_by(current_user&.id).pluck(:user_id) << current_user&.id
      end

      # 可用來判斷 current_user 是否可以簽核
      # 取得 current_user 以及其代理的人，對應的簽核紀錄
      def signing_srecords(stage, current_user)
        signer_ids = signer_ids(current_user)
        _signing_recs = stage&.srecords&.select{ |rec| rec.pending? and signer_ids.include? rec.signer_id }
        errors.add(:srecord, I18n.t("labels.doc.signing_srecords_not_found")) if _signing_recs.empty?
        _signing_recs
      end

      # 核准
      #   如果該簽核紀錄為加簽，則建立一個新的簽核紀錄給原簽核人員並發送通知
      #   如果此階段是串簽
      #     進到下一個階段或是讓申請單據簽核狀態變為核准
      #   如果此階段是會簽
      #     如果其他人也是核准，則進到下一個階段或是讓申請單據簽核狀態變為核准
      #   最後，如果此階段為最後一關，則需要從 opt 抓取參數值，來決定哪一個是決行的單據
      # 核准加簽
      # @param string opt[:waiting_stage_typing] 要加簽的簽核階段類型（串簽、會簽、擇辦）
      # @param string opt[:waiting_signer_ids] 要加簽的簽核人員，多筆以逗點分隔
      # @param integer opt[:implement_resource_record_id] 決行的單據 ID
      def approve(comment, srecords, **opt)
        Larvata::Signing::Srecord.transaction do
          srecords&.each do |rec|
            rec.state = "signed"
            rec.signing_result = "approved"
            rec.comment = comment
            rec.implement_id = opt[:implement_resource_record_id]
            rec.save!

            generate_waiting_stage(rec, **opt)

            if can_enter_next_stage?(rec) # 是否可進入到下個階段
              complete_waiting_stage(rec.stage)
              enter_next_stage(rec.stage, opt)
            end
          end
        end
      end

      # 駁回
      #   需要從 opt 抓取參數值，來決定回到哪一個簽核階段
      # @param integer opt[:return_stage_seq] 要回到哪個階段的 seq
      def reject(comment, srecords, **opt)
        Larvata::Signing::Srecord.transaction do
          srecords&.each do |rec|
            stage = rec.stage

            rec.state = "signed"
            rec.signing_result = "rejected"
            rec.comment = comment
            rec.save!

            if stage.is_first? or opt.empty? # 退回到申請人
              # 駁回的階段狀態變為已完成
              stage.state = "completed"
              stage.save!

              rejection_of_resource_records(resource_records)

              # 發送駁回通知給申請人員
              send_messages('reject', stage.id, rec.id)
            elsif opt[:return_stage_seq].present? # 退回到指定階段
              reset_stages = stages.includes(:srecords)
                .where("seq >= ? and seq <= ?", opt[:return_stage_seq], stage&.seq)
                .order(:seq)

              reset_stages.each_with_index do |_stage, index|
                # 原本還尚未簽核的紀錄，會變為「中止」
                _stage.srecords.where(signing_result: nil).update_all(state: 'terminated')

                # 會把「退回階段」到「退簽階段」之間所有簽核資料，往原本的階段再額外建立一整組空白紀錄，然後開始簽核。
                signers = _stage.srecords.map{ |r| r.attributes.slice("signer_id", "dept_id", "role") }.uniq
                _stage.srecords.create!(signers)

                if index == 0
                  _stage.signing!

                  # 發送簽核通知給申請人員
                  send_messages('signing', _stage.id)
                else
                  _stage.pending!
                end
              end
            end
          end
        end
      end

      # 核准加簽
      def generate_waiting_stage(rec, **opt)
        Larvata::Signing::Srecord.transaction do
          if opt[:waiting_stage_typing].present? and opt[:waiting_signer_ids].present?
            # 建立加簽階段，並且設定此階段狀態為 signing
            new_stage = Stage.create(larvata_signing_doc_id: rec.stage&.doc&.id, 
                                     typing: opt[:waiting_stage_typing], 
                                     parent_record_id: rec.id, 
                                     state: 'pending')

            new_stage.append_to!(rec.stage)

            # 建立加簽人員的簽核紀錄
            opt[:waiting_signer_ids]&.split(',').each do |signer_id|
              new_stage.srecords.create(signer_id: signer_id, dept_id: nil, role: nil, parent_record_id: rec.id)
            end
          end
        end
      end

      # 未決加簽
      #   需要抓取 opt 的參數值，來建立一個新的簽核紀錄給加簽人員並發送通知
      # @param string opt[:waiting_stage_typing] 要加簽的簽核階段類型（串簽、會簽、擇辦）
      # @param string opt[:waiting_signer_ids] 要加簽的簽核人員，多筆以逗點分隔
      def wait(comment, srecords, **opt)
        if opt.empty?
          errors.add(:doc, I18n.t('labels.doc.must_select_signer_for_waiting'))
          return
        end

        Larvata::Signing::Srecord.transaction do
          srecords&.each do |rec|
            rec.state = "signed"
            rec.signing_result = "waiting"
            rec.comment = comment
            rec.save!

            # 將目前階段狀態設定為 pending
            current_stage = rec.stage
            current_stage.state = 'pending'
            current_stage.save!

            # 建立加簽階段，並且設定此階段狀態為 signing
            new_stage = Stage.create(larvata_signing_doc_id: rec.stage&.doc&.id, 
                                  typing: opt[:waiting_stage_typing], 
                                  parent_record_id: rec.id, 
                                  state: 'signing')

            new_stage.append_to!(rec.stage)

            # 建立加簽人員的簽核紀錄
            opt[:waiting_signer_ids].split(',').each do |signer_id|
              new_rec = new_stage.srecords.create(signer_id: signer_id, dept_id: nil, role: nil, parent_record_id: rec.id)

              # 發送簽核通知給加簽人員
              send_messages('signing', new_stage.id, new_rec.id)
            end
          end
        end
      end

      # 判斷是否可以進入到下個階段
      # 如果可以進入下個階段，且目前階段為未決加簽，就會建立一個新的簽核紀錄給原簽核人員
      def can_enter_next_stage?(rec)
        stage = rec.stage

        if stage.sign? or stage.any_supervisor? # 串簽 or 擇辦
          # 進到下一個階段或是讓申請單據簽核狀態變為核准
          can_enter_next_stage = true
        elsif stage.counter_sign? # 會簽
          # 如果沒有其他需要簽核的紀錄，則進到下一個階段或是讓申請單據簽核狀態變為核准
          if stage.has_no_signed_srecord?
            can_enter_next_stage = true
          end
        end

        can_enter_next_stage
      end

      # 未決加簽階段在核准可進入下一關時，要將簽核流程回到指定者
      def complete_waiting_stage(stage)
        parent_record = Larvata::Signing::Srecord.includes(:stage).find_by_id(stage.parent_record_id)
        if parent_record&.waiting?
          # 建立一個新的簽核紀錄給原簽核人員
          Larvata::Signing::SrecordService
            .create_srecord_and_send_message!(parent_record&.larvata_signing_stage_id, 
                                              parent_record&.signer_id)
        end
      end

      # 進入到下個階段
      # @param integer opt[:implement_resource_record_id] 決行的單據 ID
      def enter_next_stage(stage, **opt)
        # 更新此階段狀態為已完成
        stage.update_attributes!(state: "completed")

        if stage.is_last? # 最後階段
          # 讓resource_records 簽核單原始單據編號資料的狀態變為「決行」或是「封存」
          # 依據「決行」或是「封存」來決定執行申請單據的 approved_method 和 implement_method
          implement_resource_record_id = opt[:implement_resource_record_id]
          if implement_resource_record_id.blank?
            implement_resource_record = resource_records.find_by(id: resource_records.first&.id)
          else
            implement_resource_record = resource_records.find_by(signing_resourceable_id: implement_resource_record_id)
          end
          implement_resource_record.update_attributes!(state: "implement")
          implement_resource_record.signing_resourceable.send(resource&.implement_method)

          # 剩下未決行的封存起來
          resource_records.where(state: "signing").each do |res_rec|
            res_rec.signing_resourceable&.send(resource&.approved_method)
            res_rec.update_column("state", "archived")
          end

          # 更新此簽核單為已簽核
          approved!

          # 發送核准通知給申請人
          send_messages('approve', stage.id)
        else
          next_stage = stage.next_stage

          if next_stage.inform?
            # 發送下一階段的人員通知
            send_messages('inform', next_stage.id)

            # 發送通知後，繼續往下一個階段
            enter_next_stage(next_stage)
          else
            # 更新下一階段的狀態為簽核中
            next_stage&.update_attributes!(state: "signing")

            # 發送下一階段的簽核人員通知
            send_messages('signing', next_stage.id)
          end
        end
      end

      # 發送簽核通知
      # @param typing [String] 通知類型：signing（簽核）、approve （核准）、reject（駁回）
      def send_messages(typing, stage_id = nil, srecord_id = nil)
        srecords = Larvata::Signing::Srecord
          .includes(:signer, stage: { doc: :resource })
          .where(larvata_signing_stage_id: stage_id)
        srecords = srecords.where(state: 'pending') if typing == 'signing'
        srecords = srecords.where(id: srecord_id) unless srecord_id.nil?

        srecords.each do |rec|
          if Rails.env == 'production'
            Larvata::Signing::SigningMailer.send(typing, rec).deliver_later
          else
            Larvata::Signing::SigningMailer.send(typing, rec).deliver_now
          end
        end
      end

      def validate_doc_is_signing
        errors.add(:doc, I18n.t("labels.doc.cannot_sign_when_state_is_not_signing")) unless signing?
        signing?
      end

      def set_default_values
        self.state ||= "draft"
      end

      def set_signing_number
        if signing_number.blank?
          docs_of_today = self.class.where(created_at: Time.current.midnight..Time.current.end_of_day)
          self.signing_number = "#{Time.current.strftime("%Y%m%d")}#{(docs_of_today.count+1).to_s.rjust(3, '0')}"
        end
      end
    end
  end
end
