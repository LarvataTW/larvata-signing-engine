class AddLabelMethodToLarvataSigningResource < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_resources, :label_method, :string
  end
end
