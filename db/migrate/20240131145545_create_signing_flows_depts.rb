class CreateSigningFlowsDepts < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_flows_depts do |t|
      t.bigint :larvata_signing_flow_id
      t.bigint :dept_id

      t.timestamps
    end

    add_index :larvata_signing_flows_depts, :larvata_signing_flow_id, name: 'idx_flows_depts_on_flow_id'
    add_index :larvata_signing_flows_depts, :dept_id, name: 'idx_flows_depts_on_dept_id'
  end
end
