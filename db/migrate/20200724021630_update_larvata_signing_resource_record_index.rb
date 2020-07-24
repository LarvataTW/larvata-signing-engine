class UpdateLarvataSigningResourceRecordIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :larvata_signing_resource_records, name: 'index_larvata_signing_resource_records_on_signing_resourceable' if index_exists?(:larvata_signing_resource_records, [:signing_resourceable_type, :signing_resourceable_id], name: "index_larvata_signing_resource_records_on_signing_resourceable")
    add_index :larvata_signing_resource_records, [:larvata_signing_doc_id, :signing_resourceable_type, :signing_resourceable_id], unique: true, name: 'index_larvata_signing_resource_records_on_signing_resourceable'
  end
end
