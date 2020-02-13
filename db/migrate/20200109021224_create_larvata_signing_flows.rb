class CreateLarvataSigningFlows < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_flows do |t|
      t.string :name
      t.integer :remind_period
      t.text :remark

      t.timestamps
    end
  end
end
