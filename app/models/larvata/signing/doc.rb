module Larvata::Signing
  class Doc < ApplicationRecord
    include Larvata::Signing::DocService

    # 是否在駁回或作廢時，略過不執行原單據的 returned_method，為 true 時就略過
    attribute :skip_returned_method, default: false

    if ENV['ENUM_GEM'] == 'enum_help'
      STATES = [:draft, :signing, :approved, :rejected, :void, :suspended]
    else
      STATES = {"draft" => "0", "signing" => "1", "approved" => "2", "rejected" => "3", "void" => "4", "suspended" => "5"}
    end

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
