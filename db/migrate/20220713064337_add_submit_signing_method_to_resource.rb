class AddSubmitSigningMethodToResource < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:larvata_signing_resources, :submitted_method)
      add_column :larvata_signing_resources, :submitted_method, :string
    end
  end
end
