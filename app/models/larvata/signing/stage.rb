module Larvata::Signing
  class Stage < ApplicationRecord
    include Larvata::Signing::StageService

    # TYPINGS = [:sign, :counter_sign, :any_supervisor, :inform]
    # STATES = [:pending, :signing, :completed, :terminated]
    TYPINGS = {"sign" => "0", "counter_sign" => "1", "any_supervisor" => "2", "inform" => "3"}
    STATES = {"pending" => "0", "signing" => "1", "completed" => "2", "terminated" => "3"}

    enum typing: TYPINGS
    enum state: STATES

    belongs_to :doc, class_name: "Larvata::Signing::Doc",
      foreign_key: "larvata_signing_doc_id", optional: true

    has_many :srecords, class_name: "Larvata::Signing::Srecord",
      foreign_key: "larvata_signing_stage_id", inverse_of: :stage, dependent: :destroy

    before_create :set_default_values
  end
end
