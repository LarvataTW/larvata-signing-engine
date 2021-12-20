module Larvata
  module Signing
    module ResourceRecordService

      # @param [Object] form_data 申請單據物件
      # @param [String] type 單據類型，如：Quotation
      # @param [Integer] id 單據編號
      # @param [String] doc_state 簽呈狀態（draft, signing, approved, rejected, suspended）
      # @return [Doc] 對應的簽呈物件
      def self.load_doc(form_data: nil, type: nil, id: nil, doc_state: 'signing')
        type ||= form_data.class.try(:extended_record_base_class) ? form_data.class.extended_record_base_class.to_s : form_data.class.to_s
        id ||= form_data&.id

        resource_record = resource_record_scope.includes(:doc).where(larvata_signing_docs: {state: Larvata::Signing::Doc.states[doc_state]})
                                               .find_by(signing_resourceable_type: type, signing_resourceable_id: id)
        resource_record&.doc
      end

      private

        def self.resource_record_scope
          Larvata::Signing::ResourceRecord.default_scoped
        end
    end
  end
end
