module Larvata::Signing
  class Agent < ApplicationRecord

    validates :user_id, :agent_user_id, :start_at, :end_at, presence: true

    belongs_to :user, foreign_key: "user_id", class_name: "User", optional: true
    belongs_to :agent_user, foreign_key: "agent_user_id", class_name: "User", optional: true

    # 取得傳入使用者編號
    def self.agents_by(user_id)
      where(user_id: user_id)
        .where("start_at <= ? and ? <= end_at", Time.current, Time.current)
        .pluck(:agent_user_id)
    end
  end
end
