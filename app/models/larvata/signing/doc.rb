module Larvata::Signing
  class Doc < ApplicationRecord
    include Larvata::Signing::DocService

    STATES = {"draft" => "0", "signing" => "1", "approved" => "2", "rejected" => "3", "void" => "4", "suspended" => "5"}

    enum state: STATES

    belongs_to :flow, class_name: "Larvata::Signing::Flow",
      foreign_key: "larvata_signing_flow_id", optional: true

    belongs_to :resource, class_name: "Larvata::Signing::Resource",
      foreign_key: "larvata_signing_resource_id", optional: true

    has_many :resource_records, class_name: "Larvata::Signing::ResourceRecord",
      foreign_key: "larvata_signing_doc_id", dependent: :destroy

    has_many :stages, -> { order "seq ASC" }, class_name: "Larvata::Signing::Stage",
      foreign_key: "larvata_signing_doc_id", dependent: :destroy

    has_many :srecords, class_name: "Larvata::Signing::Srecord", through: :stages

    belongs_to :applicant, foreign_key: "applicant_id", class_name: "User", optional: true

    validates_presence_of :stages
    validates_presence_of :srecords

    before_create :set_default_values
    before_save :set_signing_number
  end
end
