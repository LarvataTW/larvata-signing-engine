class AddParentRecordIdToStage < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_stages, :parent_record_id, :bigint
    add_index :larvata_signing_stages, :parent_record_id
  end
end
