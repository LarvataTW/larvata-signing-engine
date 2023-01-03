module Larvata
  module Signing
    module SrecordService
      # 建立一個新的簽核紀錄給指定簽核人員並發送通知
      def self.create_srecord_and_send_message!(stage_id, signer_id, parent_record_id = nil)
        Larvata::Signing::Srecord.transaction do
          origin_record = Larvata::Signing::Srecord.where(larvata_signing_stage_id: stage_id, signer_id: signer_id).first

          # 同個階段下，有相同的簽核人員，表示其送出的加簽已核准，要回到原送出加簽人員
          if(origin_record)
            rec = origin_record.dup
          else
            rec = Larvata::Signing::Srecord.new
          end

          rec.state = 'pending'
          rec.signing_result = nil
          rec.comment = nil
          rec.deadline = nil
          rec.waiting_reason = nil
          rec.implement_id = nil
          rec.larvata_signing_stage_id = stage_id
          rec.larvata_signing_stage_id = stage_id
          rec.signer_id = signer_id
          rec.parent_record_id = parent_record_id
          rec.created_at = Time.current
          rec.updated_at = Time.current
          rec.save!
          rec
        end
      end

      # 判斷傳入使用者是否可以簽核
      def signable?(current_user)
        doc = stage&.doc
        recs = doc.send( :signing_srecords, stage, current_user )
        recs.any?
      end

      private

      def set_default_values
        self.state ||= "pending"
      end
    end
  end
end
