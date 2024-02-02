class AddDeadlineToSrecord < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:larvata_signing_records, :deadline)
      add_column :larvata_signing_records, :deadline, :datetime
    end
  end
end
