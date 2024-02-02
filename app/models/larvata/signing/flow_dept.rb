module Larvata::Signing
  class FlowDept < ApplicationRecord
    self.table_name = "larvata_signing_flows_depts"

    belongs_to :flow, class_name: "Larvata::Signing::Flow",
               foreign_key: "larvata_signing_flow_id", optional: false
    belongs_to :dept, foreign_key: "dept_id", class_name: "Org", optional: true
  end
end
