module Larvata::Signing
  class Resource < ApplicationRecord
    has_many :flow_resources, class_name: "Larvata::Signing::FlowResource", foreign_key: "larvata_signing_resource_id"

    has_many :flows, class_name: "Larvata::Signing::Flow",
             through: :flow_resources, source: :flow
  end
end
