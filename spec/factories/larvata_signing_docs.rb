FactoryBot.define do
  factory :inquirement_doc, class: "Larvata::Signing::Doc" do
    title { "詢價單簽核單" }
    remind_period { 24 }

    trait :with_resource_records do
      after(:build) do |doc|
        inquirement_A = FactoryBot.create(:inquirement_A)
        inquirement_B = FactoryBot.create(:inquirement_B)
        inquirement_C = FactoryBot.create(:inquirement_C)

        doc.resource_records << FactoryBot.build(:inquirement_resource_record_A, signing_resourceable_id: inquirement_A.id)
        doc.resource_records << FactoryBot.build(:inquirement_resource_record_B, signing_resourceable_id: inquirement_B.id)
        doc.resource_records << FactoryBot.build(:inquirement_resource_record_C, signing_resourceable_id: inquirement_C.id)
      end
    end

    trait :with_stages do 
      after(:build) do |doc|
        doc.stages << FactoryBot.build(:supervisor_stage, :with_supervisor)
        doc.stages << FactoryBot.build(:other_dept_managers_stage, :with_other_dept_managers)
        doc.stages << FactoryBot.build(:president_stage, :with_president)
      end
    end
  end
end
