class AddApplicantComAndDeptToDoc < ActiveRecord::Migration[5.1]
  def change
    unless column_exists?(:larvata_signing_records, :deadline)
      add_column :larvata_signing_docs, :applicant_com_id, :bigint
    end
    unless index_exists?(:larvata_signing_docs, :applicant_com_id)
      add_index :larvata_signing_docs, :applicant_com_id
    end
    unless column_exists?(:larvata_signing_docs, :applicant_dept_id)
      add_column :larvata_signing_docs, :applicant_dept_id, :bigint
    end
    unless index_exists?(:larvata_signing_docs, :applicant_dept_id)
      add_index :larvata_signing_docs, :applicant_dept_id
    end
  end
end
