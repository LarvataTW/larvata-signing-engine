module Larvata::Signing
  class FlowStage < ApplicationRecord
    if ENV['ENUM_GEM'] == 'enum_help'
      TYPINGS = [:sign, :counter_sign, :any_supervisor, :inform]
    else
      TYPINGS = {"sign" => "0", "counter_sign" => "1", "any_supervisor" => "2", "inform" => "3"}
    end

    enum typing: TYPINGS

    belongs_to :flow, class_name: "Larvata::Signing::Flow",
      foreign_key: "larvata_signing_flow_id", optional: true

    has_many :flow_members, class_name: "Larvata::Signing::FlowMember",
      foreign_key: "larvata_signing_flow_stage_id"
  end
end
