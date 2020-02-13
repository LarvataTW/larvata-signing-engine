module ActionMailer
  def self.clean_deliveries
    ActionMailer::Base.deliveries = []
  end
end
