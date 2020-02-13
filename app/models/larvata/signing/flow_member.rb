module Larvata::Signing
  class FlowMember < ApplicationRecord
    belongs_to :stage, class_name: "Larvata::Signing::FlowStage", 
      foreign_key: "larvata_signing_flow_stage_id", optional: true

    belongs_to :user, class_name: "User", optional: true
  end
end
