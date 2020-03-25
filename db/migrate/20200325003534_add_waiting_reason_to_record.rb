class AddWaitingReasonToRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_records, :waiting_reason, :text
  end
end
