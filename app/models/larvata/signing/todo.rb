module Larvata::Signing
  class Todo < ApplicationRecord
    if ENV['ENUM_GEM'] == 'enum_help'
      TYPING = [:signing_doc, :notice]
    else
      TYPING = {"signing_doc" => "0", "notice" => "1"}
    end

    enum state: TYPING

    belongs_to :user, foreign_key: "user_id", class_name: "User", optional: true
  end
end
