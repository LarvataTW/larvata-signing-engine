FactoryBot.define do
  factory :supervisor_flow_stage, class: "Larvata::Signing::FlowStage" do
    typing { "sign" }
    seq { 1 }
    supervisor_sign { true }
  end

  factory :other_dept_managers_flow_stage, class: "Larvata::Signing::FlowStage" do
    typing { "counter_sign" }
    seq { 2 }
    supervisor_sign { false }

    trait :with_other_dept_managers do
      after(:build) do |m|
        m.flow_members << FactoryBot.build(:sales_manager, :with_user)
        m.flow_members << FactoryBot.build(:construction_manager, :with_user)
      end
    end
  end

  factory :president_flow_stage, class: "Larvata::Signing::FlowStage" do
    typing { "sign" }
    seq { 3 }
    supervisor_sign { false }

    trait :with_president do
      after(:build) do |m|
        m.flow_members << FactoryBot.build(:president, :with_user)
      end
    end
  end
end
