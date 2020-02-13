class Inquirement < ApplicationRecord
  STATES = [:draft, :evaluating, :evaluated, :signing, :contracted, :archived]

  enum state: STATES

  before_create :set_default_values

  def signing_returned
    self.evaluated!
  end

  def signing_approved
    self.archived!
  end

  def signing_implement
    self.contracted!
  end

  private 

  def set_default_values
    self.state = 'signing'
  end
end
