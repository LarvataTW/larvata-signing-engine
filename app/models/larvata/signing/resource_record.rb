module Larvata::Signing
  class ResourceRecord < ApplicationRecord
    # STATES = [:pending, :signing, :rejected, :implement, :archived]
    STATES = {"pending" => "0", "signing" => "1", "rejected" => "2", "implement" => "3", "archived" => "4"}

    enum state: STATES

    belongs_to :signing_resourceable, polymorphic: true, optional: true

    belongs_to :doc, class_name: "Larvata::Signing::Doc",
      foreign_key: "larvata_signing_doc_id", optional: true

    before_create :set_default_values

    private

    def set_default_values
      self.state ||= "pending"
    end
  end
end
