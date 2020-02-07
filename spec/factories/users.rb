FactoryBot.define do
  factory :applicant_user, class: "User" do
    name { "單據申請人" }
  end

  factory :supervisor_user, class: "User" do
    name { "主管" }
  end

  factory :construction_manager_user, class: "User" do
    name { "工務經理" }
  end

  factory :sales_manager_user, class: "User" do
    name { "業務經理" }
  end

  factory :president_user, class: "User" do
    name { "總經理" }
  end

  factory :financial_manager_user, class: "User" do 
    name { "財務經理" }
  end
end

