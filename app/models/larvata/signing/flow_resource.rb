module Larvata::Signing
  class FlowResource < ApplicationRecord
    self.table_name = "larvata_signing_flows_resources"

    belongs_to :flow, class_name: "Larvata::Signing::Flow",
               foreign_key: "larvata_signing_flow_id", optional: false
    belongs_to :resource, class_name: "Larvata::Signing::Resource",
               foreign_key: "larvata_signing_resource_id", optional: false
  end
end
