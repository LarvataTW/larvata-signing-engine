class CreateLarvataSigningRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_records do |t|
      t.references :larvata_signing_stage, foreign_key: true
      t.bigint :signer_id
      t.bigint :dept_id
      t.string :role
      t.integer :signing_result
      t.text :comment
      t.bigint :parent_record_id
      t.integer :state

      t.timestamps
    end
    add_index :larvata_signing_records, :signer_id
    add_index :larvata_signing_records, :dept_id
    add_index :larvata_signing_records, :signing_result
    add_index :larvata_signing_records, :parent_record_id
    add_index :larvata_signing_records, :state
  end
end
