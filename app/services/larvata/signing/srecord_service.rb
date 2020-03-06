module Larvata
  module Signing
    module SrecordService
      # 建立一個新的簽核紀錄給指定簽核人員並發送通知
      def self.create_srecord_and_send_message!(stage_id, signer_id, parent_record_id = nil)
        Larvata::Signing::Srecord.transaction do
          rec = Larvata::Signing::Srecord.new
          rec.larvata_signing_stage_id = stage_id
          rec.signer_id = signer_id
          rec.parent_record_id = parent_record_id
          rec.save!
          rec
        end
      end

      private

      def set_default_values
        self.state ||= "pending"
      end
    end
  end
end
