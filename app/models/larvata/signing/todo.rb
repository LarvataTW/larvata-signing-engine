module Larvata::Signing
  class Todo < ApplicationRecord
    # TYPING = [:signing_doc, :notice]
    TYPING = {"signing_doc" => "0", "notice" => "1"}

    enum state: TYPING

    belongs_to :user, foreign_key: "user_id", class_name: "User", optional: true
  end
end
