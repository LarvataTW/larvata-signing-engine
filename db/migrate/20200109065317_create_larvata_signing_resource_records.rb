class CreateLarvataSigningResourceRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_resource_records do |t|
      t.references :larvata_signing_doc, foreign_key: true, index: {name: 'index_larvata_signing_resource_records_on_signing_doc_id'}
      t.string :signing_resourceable_type
      t.bigint :signing_resourceable_id
      t.integer :state

      t.timestamps
    end
    add_index :larvata_signing_resource_records, :state
    add_index :larvata_signing_resource_records, [:signing_resourceable_type, :signing_resourceable_id], unique: true, name: 'index_larvata_signing_resource_records_on_signing_resourceable'
  end
end
