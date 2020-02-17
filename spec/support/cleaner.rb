module Cleaner
  def self.clean_messages
    ActionMailer.clean_deliveries
    Larvata::Signing::Todo.delete_all
  end
end
