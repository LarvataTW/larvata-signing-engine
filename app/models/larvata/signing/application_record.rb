module Larvata
  module Signing
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
