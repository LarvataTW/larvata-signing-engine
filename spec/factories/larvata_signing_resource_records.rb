FactoryBot.define do
  factory :inquirement_resource_record_A, class: "Larvata::Signing::ResourceRecord" do
    signing_resourceable_id { 1 }
    signing_resourceable_type { "Inquirement" }
  end

  factory :inquirement_resource_record_B, class: "Larvata::Signing::ResourceRecord" do
    signing_resourceable_id { 2 }
    signing_resourceable_type { "Inquirement" }
  end

  factory :inquirement_resource_record_C, class: "Larvata::Signing::ResourceRecord" do
    signing_resourceable_id { 3 }
    signing_resourceable_type { "Inquirement" }
  end
end
