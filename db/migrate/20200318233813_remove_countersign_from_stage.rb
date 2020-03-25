class RemoveCountersignFromStage < ActiveRecord::Migration[5.1]
  def change
    remove_column :larvata_signing_stages, :countersign, :boolean
  end
end
