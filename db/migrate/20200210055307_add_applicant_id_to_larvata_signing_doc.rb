class AddApplicantIdToLarvataSigningDoc < ActiveRecord::Migration[5.1]
  def change
    add_column :larvata_signing_docs, :applicant_id, :bigint
    add_index :larvata_signing_docs, :applicant_id
  end
end
