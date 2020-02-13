class CreateInquirements < ActiveRecord::Migration[5.1]
  def change
    create_table :inquirements do |t|
      t.string :name
      t.integer :state

      t.timestamps
    end
  end
end
