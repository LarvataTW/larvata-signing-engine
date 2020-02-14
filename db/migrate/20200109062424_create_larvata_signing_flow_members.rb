class CreateLarvataSigningFlowMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_flow_members do |t|
      t.references :larvata_signing_flow_stage, foreign_key: true, index: {name: 'index_larvata_signing_flow_memberds_on_flow_stage_id'}
      t.bigint :dept_id
      t.bigint :user_id
      t.string :role

      t.timestamps
    end
    add_index :larvata_signing_flow_members, :dept_id
    add_index :larvata_signing_flow_members, :user_id
  end
end
