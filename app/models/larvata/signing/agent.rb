module Larvata::Signing
  class Agent < ApplicationRecord
    def self.agent_user_ids(user_id)
      where(user_id: user_id)
        .where("start_at <= ? and ? <= end_at", Time.current, Time.current)
        .pluck(:agent_user_id)
    end
  end
end
