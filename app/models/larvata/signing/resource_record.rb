module Larvata::Signing
  class ResourceRecord < ApplicationRecord
    if ENV['ENUM_GEM'] == 'enum_help'
      STATES = [:pending, :signing, :rejected, :implement, :archived]
    else
      STATES = {"pending" => "0", "signing" => "1", "rejected" => "2", "implement" => "3", "archived" => "4"}
    end

    enum state: STATES

    belongs_to :signing_resourceable, polymorphic: true, optional: true

    belongs_to :doc, class_name: "Larvata::Signing::Doc",
      foreign_key: "larvata_signing_doc_id", optional: true

    before_create :set_default_values

    # 找出可以建立簽呈資料的單據
    # @param model_class [單據類別] 要建立簽呈的單據種類，如 Quotation
    # @param select_method [String] 單據類別中，可以提供可送簽呈的單據資料之查詢方法，如 signable
    # @param signing_resourceable_ids [Array] 指定要查詢出的單據編號
    def self.load_not_signing(model_class, select_method, signing_resourceable_ids = nil)
      model_class = model_class.send(select_method)
      model_class = model_class.where(id: signing_resourceable_ids) if signing_resourceable_ids.present?
      model_class = model_class.where.not(id: not_pending.specific_type(model_class.name).select(:signing_resourceable_id))
      return model_class
    end

    private

    def set_default_values
      self.state ||= "pending"
    end
  end
end
