FactoryBot.define do
  factory :supervisor_stage, class: "Larvata::Signing::Stage" do
    typing { "sign" }
    seq { 1 }

    trait :with_supervisor do
      after(:build) do |m|
        m.records << FactoryBot.build(:supervisor_record)
      end
    end
  end

  factory :other_dept_managers_stage, class: "Larvata::Signing::Stage" do
    typing { "counter_sign" }
    seq { 2 }

    trait :with_other_dept_managers do
      after(:build) do |m|
        m.records << FactoryBot.build(:sales_manager_record)
        m.records << FactoryBot.build(:construction_manager_record)
      end
    end
  end

  factory :president_stage, class: "Larvata::Signing::Stage" do
    typing { "sign" }
    seq { 3 }

    trait :with_president do
      after(:build) do |m|
        m.records << FactoryBot.build(:president_record)
      end
    end
  end
end
