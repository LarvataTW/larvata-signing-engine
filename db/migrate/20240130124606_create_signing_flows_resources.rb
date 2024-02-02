class CreateSigningFlowsResources < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_flows_resources do |t|
      t.bigint :larvata_signing_flow_id
      t.bigint :larvata_signing_resource_id

      t.timestamps
    end

    add_index :larvata_signing_flows_resources, :larvata_signing_flow_id, name: 'idx_flows_resources_on_flow_id'
    add_index :larvata_signing_flows_resources, :larvata_signing_resource_id, name: 'idx_flows_resources_on_resource_id'
  end
end
