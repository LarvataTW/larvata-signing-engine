module Larvata::Signing
  class Record < ApplicationRecord
    SIGNING_RESULTS = [:waiting, :rejected, :approved]
    STATES = [:pending, :notify, :terminated, :signed]

    enum state: STATES
    enum signing_result: SIGNING_RESULTS

    belongs_to :stage, class_name: "Larvata::Signing::Stage", 
      foreign_key: "larvata_signing_stage_id", optional: true, inverse_of: :records

    belongs_to :parent_record, class_name: "Larvata::Signing::Record", 
      foreign_key: "parent_record_id", optional: true

    belongs_to :signer, foreign_key: "signer_id", class_name: "User", optional: true

    before_create :set_default_values

    # 建立一個新的簽核紀錄給指定簽核人員並發送通知
    def self.create_record_and_send_message!(stage_id, signer_id, parent_record_id = nil)
      Larvata::Signing::Record.transaction do 
        rec = Larvata::Signing::Record.new
        rec.larvata_signing_stage_id = stage_id
        rec.signer_id = signer_id
        rec.parent_record_id = parent_record_id 
        rec.save!

        # TBD 發送簽核通知
      end
    end

    private

    def set_default_values
      self.state ||= "pending"
    end
  end
end
