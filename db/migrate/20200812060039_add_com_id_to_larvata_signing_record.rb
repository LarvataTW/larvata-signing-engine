class AddComIdToLarvataSigningRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_records, :com_id, :bigint
    add_index :larvata_signing_records, :com_id
  end
end
