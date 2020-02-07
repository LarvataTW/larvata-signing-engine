module Larvata::Signing
  class Resource < ApplicationRecord
    belongs_to :flow, class_name: "Larvata::Signing::Flow", 
      foreign_key: "larvata_signing_flow_id", optional: true
  end
end
