class AddImplementIdToRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_records, :implement_id, :bigint
  end
end
