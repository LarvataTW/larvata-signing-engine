module Larvata::Signing
  class Agent < ApplicationRecord
    # 取得傳入使用者編號
    def self.agents_by(user_id)
      where(user_id: user_id)
        .where("start_at <= ? and ? <= end_at", Time.current, Time.current)
        .pluck(:agent_user_id)
    end
  end
end
