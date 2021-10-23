module Larvata::Signing
  class Srecord < ApplicationRecord
    include Larvata::Signing::SrecordService

    self.table_name = "larvata_signing_records"

    # SIGNING_RESULTS = [:waiting, :rejected, :approved]
    # STATES = [:pending, :notify, :terminated, :signed]
    SIGNING_RESULTS = {"waiting" => "0", "rejected" => "1", "approved" => "2"}
    STATES = {"pending" => "0", "notify" => "1", "terminated" => "2", "signed" => "3"}

    enum state: STATES
    enum signing_result: SIGNING_RESULTS

    belongs_to :stage, class_name: "Larvata::Signing::Stage",
      foreign_key: "larvata_signing_stage_id", optional: true, inverse_of: :srecords

    belongs_to :parent_srecord, class_name: "Larvata::Signing::Srecord",
      foreign_key: "parent_record_id", optional: true

    belongs_to :signer, foreign_key: "signer_id", class_name: "User", optional: true

    before_create :set_default_values
  end
end
