FactoryBot.define do
  factory :construction_manager, class: "Larvata::Signing::FlowMember" do
    dept_id { 2 }
    role { "工務經理" }

    trait :with_user do
      after(:build) do |m|
        m.user = FactoryBot.build(:construction_manager_user)
      end
    end
  end

  factory :sales_manager, class: "Larvata::Signing::FlowMember" do
    dept_id { 3 }
    role { "業務經理" }

    trait :with_user do
      after(:build) do |m|
        m.user = FactoryBot.build(:sales_manager_user)
      end
    end
  end

  factory :president, class: "Larvata::Signing::FlowMember" do
    dept_id { 4 }
    role { "總經理" }

    trait :with_user do
      after(:build) do |m|
        m.user = FactoryBot.build(:president_user)
      end
    end
  end
end
