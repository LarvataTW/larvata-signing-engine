FactoryBot.define do
  factory :applicant_user, class: "User" do
    name { "單據申請人" }
    email { "applicant_user@larvata.tw" }
  end

  factory :supervisor_user, class: "User" do
    name { "主管" }
    email { "supervisor_user@larvata.tw" }
  end

  factory :construction_manager_user, class: "User" do
    name { "工務經理" }
    email { "construction_manager_user@larvata.tw" }
  end

  factory :sales_manager_user, class: "User" do
    name { "業務經理" }
    email { "sales_manager_user@larvata.tw" }
  end

  factory :president_user, class: "User" do
    name { "總經理" }
    email { "president_user@larvata.tw" }
  end

  factory :financial_manager_user, class: "User" do 
    name { "財務經理" }
    email { "financial_manager_user@larvata.tw" }
  end
end

