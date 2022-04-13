class AddApplicantComAndDeptToDoc < ActiveRecord::Migration[6.1]
  def change
    add_column :docs, :applicant_com_id, :bigint
    add_index :docs, :applicant_com_id
    add_column :docs, :applicant_dept_id, :bigint
    add_index :docs, :applicant_dept_id
  end
end
