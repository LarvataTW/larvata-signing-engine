class AddSubmitSigningMethodToResource < ActiveRecord::Migration[6.1]
  def change
    add_column :larvata_signing_resources, :submitted_method, :string
  end
end
