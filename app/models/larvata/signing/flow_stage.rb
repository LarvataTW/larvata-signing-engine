module Larvata::Signing
  class FlowStage < ApplicationRecord
    TYPINGS = [:sign, :counter_sign, :any_supervisor, :inform]

    enum typing: TYPINGS

    belongs_to :flow, class_name: "Larvata::Signing::Flow", 
      foreign_key: "larvata_signing_flow_id", optional: true

    has_many :flow_members, class_name: "Larvata::Signing::FlowMember", 
      foreign_key: "larvata_signing_flow_stage_id"
  end
end
