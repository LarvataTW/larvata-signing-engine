class AddDeadlineToSrecord < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_records, :deadline, :datetime
  end
end
