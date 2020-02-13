class CreateLarvataSigningAgents < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_agents do |t|
      t.bigint :user_id
      t.bigint :agent_user_id
      t.datetime :start_at
      t.datetime :end_at
      t.text :remark

      t.timestamps
    end
    add_index :larvata_signing_agents, :user_id
    add_index :larvata_signing_agents, :agent_user_id
  end
end
