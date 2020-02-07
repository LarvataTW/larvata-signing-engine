class CreateLarvataSigningFlowStages < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_flow_stages do |t|
      t.references :larvata_signing_flow, foreign_key: true
      t.integer :typing
      t.integer :seq
      t.boolean :supervisor_sign
      t.text :filter_condition

      t.timestamps
    end
    add_index :larvata_signing_flow_stages, :typing
  end
end
