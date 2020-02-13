class CreateLarvataSigningStages < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_stages do |t|
      t.references :larvata_signing_doc, foreign_key: true
      t.integer :typing
      t.integer :seq
      t.boolean :countersign
      t.integer :state

      t.timestamps
    end
    add_index :larvata_signing_stages, :typing
    add_index :larvata_signing_stages, :state
  end
end
