module Larvata::Signing
  class Doc < ApplicationRecord
    include Larvata::Signing::DocService

    STATES = [:draft, :rejected, :signing, :void, :approved]

    enum state: STATES

    belongs_to :flow, class_name: "Larvata::Signing::Flow", 
      foreign_key: "larvata_signing_flow_id", optional: true

    belongs_to :resource, class_name: "Larvata::Signing::Resource", 
      foreign_key: "larvata_signing_resource_id", optional: true

    has_many :resource_records, class_name: "Larvata::Signing::ResourceRecord", 
      foreign_key: "larvata_signing_doc_id", dependent: :destroy

    has_many :stages, -> { order "seq ASC" }, class_name: "Larvata::Signing::Stage", 
      foreign_key: "larvata_signing_doc_id", dependent: :destroy

    has_many :srecords, class_name: "Larvata::Signing::Srecord", through: :stages, dependent: :destroy

    belongs_to :applicant, foreign_key: "applicant_id", class_name: "User", optional: true

    before_create :set_default_values
    before_save :set_signing_number

    def self.states_i18n
      states.inject({}) {|h, (k, v)|  h[k] = I18n.t("enums.doc.state.#{k}") || v; h}
    end

    private 

    def set_default_values
      self.state ||= "draft"
    end

    def set_signing_number
      if signing_number.blank?
        docs_of_today = self.class.where(created_at: Time.current.midnight..Time.current.end_of_day)
        self.signing_number = "#{Time.current.strftime("%Y%m%d")}#{(docs_of_today.count+1).to_s.rjust(3, '0')}" 
      end
    end
  end
end
