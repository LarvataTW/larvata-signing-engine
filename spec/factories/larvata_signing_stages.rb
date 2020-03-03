FactoryBot.define do
  factory :supervisor_stage, class: "Larvata::Signing::Stage" do
    typing { "sign" }
    seq { 1 }

    trait :with_supervisor do
      after(:build) do |m|
        m.srecords << FactoryBot.build(:supervisor_srecord)
      end
    end
  end

  factory :other_dept_managers_stage, class: "Larvata::Signing::Stage" do
    typing { "counter_sign" }
    seq { 2 }

    trait :with_other_dept_managers do
      after(:build) do |m|
        m.srecords << FactoryBot.build(:sales_manager_srecord)
        m.srecords << FactoryBot.build(:construction_manager_srecord)
      end
    end
  end

  factory :president_stage, class: "Larvata::Signing::Stage" do
    typing { "sign" }
    seq { 3 }

    trait :with_president do
      after(:build) do |m|
        m.srecords << FactoryBot.build(:president_srecord)
      end
    end
  end
end
