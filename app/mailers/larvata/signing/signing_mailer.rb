module Larvata::Signing
  class SigningMailer < ApplicationMailer
    include Rails.application.routes.url_helpers

    # 簽核通知
    def signing(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      mail(to: rec.signer.email, subject: "有新的#{rec.stage&.doc&.resource&.name}簽核單需要簽核")
    end

    # 駁回通知
    def reject(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      mail(to: rec.stage&.doc&.applicant&.email, subject: "您的#{rec.stage&.doc&.resource&.name}簽核單被駁回了")
    end

    # 駁回通知
    def approve(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      mail(to: rec.stage&.doc&.applicant&.email, subject: "您的#{rec.stage&.doc&.resource&.name}簽核單被核准了")
    end
  end
end
