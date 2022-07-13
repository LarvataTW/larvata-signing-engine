class AddApplicantComAndDeptToDoc < ActiveRecord::Migration[6.1]
  def change
    add_column :larvata_signing_docs, :applicant_com_id, :bigint
    add_index :larvata_signing_docs, :applicant_com_id
    add_column :larvata_signing_docs, :applicant_dept_id, :bigint
    add_index :larvata_signing_docs, :applicant_dept_id
  end
end
