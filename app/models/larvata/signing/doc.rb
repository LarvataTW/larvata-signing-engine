module Larvata::Signing
  class Doc < ApplicationRecord
    STATES = [:draft, :rejected, :signing, :void, :approved]

    enum state: STATES

    belongs_to :flow, class_name: "Larvata::Signing::Flow", 
      foreign_key: "larvata_signing_flow_id", optional: true

    belongs_to :resource, class_name: "Larvata::Signing::Resource", 
      foreign_key: "larvata_signing_resource_id", optional: true

    has_many :resource_records, class_name: "Larvata::Signing::ResourceRecord", 
      foreign_key: "larvata_signing_doc_id"

    has_many :stages, -> { order "seq ASC" }, class_name: "Larvata::Signing::Stage", 
      foreign_key: "larvata_signing_doc_id"

    has_many :records, class_name: "Larvata::Signing::Record", through: :stages

    before_create :set_default_values
    before_save :set_signing_number

    # 簽核邏輯：https://projects.larvata.tw/issues/70725
    def sign(current_user, signing_result, comment, opt = nil)
      records = signing_records(signing_stage, current_user)

      send(signing_result, comment, records, opt)

      self
    end

    private 

    def set_default_values
      self.state ||= "draft"
    end

    def set_signing_number
      docs_of_today = self.class.where(created_at: Time.current.midnight..Time.current.end_of_day)
      self.signing_number ||= "#{Time.current.strftime("%F")}#{(docs_of_today.count+1).to_s.rjust(3, '0')}"
    end

    # 目前需要簽核的階段
    def signing_stage
      Larvata::Signing::Stage.signing.includes(:doc, :records).where(larvata_signing_doc_id: id).first
    end

    # 抓取 current_user 以及其代理的人
    def signer_ids(current_user)
      Larvata::Signing::Agent.agent_user_ids(current_user&.id) << current_user&.id
    end

    # 取得 current_user 以及其代理的人，對應的簽核紀錄
    def signing_records(stage, current_user)
      signer_ids = signer_ids(current_user)
      _signing_recs = stage&.records&.select{ |rec| rec.pending? and signer_ids.include? rec.signer_id }
      errors.add(:record, I18n.t("labels.doc.signing_records_not_found")) if _signing_recs.empty?
      _signing_recs
    end

    # 退回到指定階段
    def return_to_stage(stage_id)

    end

    # 退回到單據申請人
    def return_to_applicant

    end

    # 決行單據
    def implement_application(application_id)

    end

    # 核准
    #   如果該簽核紀錄為加簽，則建立一個新的簽核紀錄給原簽核人員並發送通知
    #   如果此階段是串簽
    #     進到下一個階段或是讓申請單據簽核狀態變為核准
    #   如果此階段是會簽
    #     如果其他人也是核准，則進到下一個階段或是讓申請單據簽核狀態變為核准
    #   最後，如果此階段為最後一關，則需要從 opt* 抓取參數值，來決定哪一個是決行的單據
    def approve(comment, records, opt = nil)
      Larvata::Signing::Record.transaction do 
        records&.each do |rec|
          rec.state = "signed"
          rec.signing_result = "approved"
          rec.comment = comment
          rec.save!

          if can_enter_next_stage?(rec) # 是否可進入到下個階段
            enter_next_stage(rec, opt)
          end
        end
      end
    end

    # 駁回
    #   需要從 opt 抓取參數值，來決定回到哪一個簽核階段
    def reject(comment, records, opt = nil)
      Larvata::Signing::Record.transaction do 
        records&.each do |rec|
          stage = rec.stage

          rec.state = "signed"
          rec.signing_result = "rejected"
          rec.comment = comment
          rec.save!

          if stage.is_first? or opt.nil? # 退回到申請人
            # 駁回的階段狀態變為已完成
            stage.state = "completed"
            stage.save!

            # 讓resource_records 簽核單原始單據編號資料的狀態變為「駁回」
            resource_records.update_all(state: "rejected")

            # 執行申請單據的 return_method
            resource_records.each do |res_rec|
              res_rec.signing_resourceable&.send(resource&.returned_method)
            end

            # TBD 發送駁回通知給申請人員
          elsif opt.present? # 退回到指定階段
            reset_stages = stages.includes(:records).where("seq >= ? and seq <= ?", opt, stage&.seq)
            reset_stages.each_with_index do |s, index|
              # 原本還尚未簽核的紀錄，會變為「中止」
              s.records.where(signing_result: nil).update(state: 'terminated')

              # 會把「退回階段」到「退簽階段」之間所有簽核資料，往原本的階段再額外建立一整組空白紀錄，然後開始簽核。
              signers = s.records.map{ |r| r.attributes.slice(:signer_id, :dept_id, :role) }.uniq
              s.records.create!(signers)

              if index == 0
                s.state = 'signing'
              else
                s.state = 'pending'
              end

              s.save!

              # TBD 發送簽核通知給申請人員
            end
          end
        end
      end
    end

    # 加簽
    #   需要抓取 opt 的參數值，來建立一個新的簽核紀錄給加簽人員並發送通知
    def waiting(comment, records, opt = nil)
      if opt.nil?
        errors.add(:doc, I18n.t('labels.doc.must_select_signer_for_waiting'))
        return
      end

      Larvata::Signing::Record.transaction do 
        records&.each do |rec|
          rec.state = "signed"
          rec.signing_result = "waiting"
          rec.comment = comment
          rec.save!

          # 建立加簽人員的簽核紀錄
          rec.stage.records.create(signer_id: opt, dept_id: nil, role: nil, parent_record_id: rec.id)

          # TBD 發送簽核通知給加簽人員
        end
      end
    end

    # 判斷是否可以進入到下個階段
    def can_enter_next_stage?(rec)
      stage = rec.stage
      if rec.parent_record_id.present? # 加簽
        # 建立一個新的簽核紀錄給原簽核人員
        parent_rec = Larvata::Signing::Record.find_by(rec.parent_record_id)
        Larvata::Signing::Record.create_record_and_send_message!(parent_rec&.stage_id, parent_rec&.signer_id)

        # TBD 發送簽核通知給原簽核人員
      elsif stage.sign? # 串簽
        # 進到下一個階段或是讓申請單據簽核狀態變為核准
        can_enter_next_stage = true
      elsif stage.counter_sign? # 會簽
        # 如果沒有其他需要簽核的紀錄，則進到下一個階段或是讓申請單據簽核狀態變為核准
        if stage.has_no_signed_record?
          can_enter_next_stage = true
        end
      end

      can_enter_next_stage
    end

    # 進入到下個階段
    def enter_next_stage(rec, opt)
      stage = rec.stage
      if stage.is_last? # 最後階段
        # 讓resource_records 簽核單原始單據編號資料的狀態變為「決行」或是「封存」
        implement_resource_id = opt || resource_records.first&.id
        resource_records.where(signing_resourceable_id: implement_resource_id).update_attributes!(state: "implement")
        resource_records.where(state: "signing").update_attributes!(state: "archived")

        # 依據「決行」或是「封存」來決定執行申請單據的 approved_method 和 implement_method 
        resource_records.each do |res_rec|
          res_rec.signing_resouceable&.send(resource&.implement_method) if res_rec.implement?
          res_rec.signing_resouceable&.send(resource&.approved_method) if res_rec.archived?
        end
      else
        # 更新此階段狀態為已完成
        stage.update_attributes!(state: "completed")

        # 更新下一階段的狀態為簽核中
        next_stage = stage.next_stage
        next_stage&.update_attributes!(state: "signing")

        # TBD 發送下一階段的簽核人員通知
      end
    end
  end
end
