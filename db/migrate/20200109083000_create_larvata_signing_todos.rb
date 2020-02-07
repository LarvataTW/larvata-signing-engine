class CreateLarvataSigningTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :larvata_signing_todos do |t|
      t.bigint :user_id
      t.integer :typing
      t.string :title
      t.text :url
      t.text :remark

      t.timestamps
    end
    add_index :larvata_signing_todos, :user_id
    add_index :larvata_signing_todos, :typing
  end
end
