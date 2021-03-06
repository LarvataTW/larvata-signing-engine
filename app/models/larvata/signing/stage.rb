module Larvata::Signing
  class Stage < ApplicationRecord
    include Larvata::Signing::StageService

    TYPINGS = [:sign, :counter_sign, :any_supervisor, :inform]
    STATES = [:pending, :signing, :completed, :terminated]

    enum typing: TYPINGS
    enum state: STATES

    belongs_to :doc, class_name: "Larvata::Signing::Doc", 
      foreign_key: "larvata_signing_doc_id", optional: true

    has_many :srecords, class_name: "Larvata::Signing::Srecord", 
      foreign_key: "larvata_signing_stage_id", inverse_of: :stage, dependent: :destroy

    before_create :set_default_values
  end
end
