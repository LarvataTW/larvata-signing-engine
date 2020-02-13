FactoryBot.define do
  factory :inquirement_resource, class: "Larvata::Signing::Resource" do
    code { "inquirement" }
    name { "詢價單" }
    select_model { "Inquirement" }
    select_method { "options_for_signing" }
    view_path { "admin_inquirement_path" }
    returned_method { "signing_returned" }
    approved_method { "signing_approved" }
    implement_method { "signing_implement" }
  end
end
