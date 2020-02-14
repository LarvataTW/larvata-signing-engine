FactoryBot.define do
  factory :supervisor_record, class: "Larvata::Signing::Record" do
    dept_id { 1 }
    signer_id { 2 }
    role { "主管" }
  end

  factory :construction_manager_record, class: "Larvata::Signing::Record" do
    dept_id { 2 }
    signer_id { 3 }
    role { "工務經理" }
  end

  factory :sales_manager_record, class: "Larvata::Signing::Record" do
    dept_id { 3 }
    signer_id { 4 }
    role { "業務經理" }
  end

  factory :president_record, class: "Larvata::Signing::Record" do
    dept_id { 4 }
    signer_id { 6 }
    role { "總經理" }
  end
end
