class AddCommittedAtToDoc < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_docs, :committed_at, :datetime
  end
end
