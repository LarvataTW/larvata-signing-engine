FactoryBot.define do
  factory :inquirement_flow, class: "Larvata::Signing::Flow" do
    name { "詢價單簽核流程" }
    remind_period { 24 }

    trait :with_resources do
      after(:build) do |flow|
        flow.resources << FactoryBot.build(:inquirement_resource)
      end
    end

    trait :with_flow_stages do
      after(:build) do |flow|
        flow.signing_flow_stages << FactoryBot.build(:supervisor_flow_stage)
        flow.signing_flow_stages << FactoryBot.build(:other_dept_managers_flow_stage, :with_other_dept_managers)
        flow.signing_flow_stages << FactoryBot.build(:president_flow_stage, :with_president)
      end
    end
  end
end
