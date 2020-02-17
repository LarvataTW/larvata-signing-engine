module Larvata::Signing
  class Todo < ApplicationRecord
    TYPING = [:signing_doc, :notice]

    enum state: TYPING

    belongs_to :user, foreign_key: "user_id", class_name: "User", optional: true
  end
end
