class CreateLarvataSigningResources < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_resources do |t|
      t.string :code
      t.string :name
      t.string :select_model
      t.string :select_method
      t.string :view_path
      t.string :returned_method
      t.string :approved_method
      t.string :implement_method
      t.references :larvata_signing_flow, foreign_key: true

      t.timestamps
    end
    add_index :larvata_signing_resources, :code
  end
end
