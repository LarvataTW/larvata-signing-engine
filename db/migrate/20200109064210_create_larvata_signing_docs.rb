class CreateLarvataSigningDocs < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_docs do |t|
      t.references :larvata_signing_flow, foreign_key: true
      t.references :larvata_signing_resource, foreign_key: true
      t.string :signing_number
      t.string :title
      t.text :remark
      t.integer :remind_period
      t.integer :state

      t.timestamps
    end
    add_index :larvata_signing_docs, :signing_number
    add_index :larvata_signing_docs, :title
    add_index :larvata_signing_docs, :state
  end
end
