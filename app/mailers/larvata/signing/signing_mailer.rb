module Larvata::Signing
  class SigningMailer < ApplicationMailer
    include Rails.application.routes.url_helpers

    # 簽核通知
    def signing(rec)
      @rec = rec
      @admin_signing_doc_url = send(Larvata::Signing.admin_singing_doc_url, @rec.stage&.doc&.id)
      user = rec.signer
      title = "「#{rec.stage&.doc&.title}」需要您簽核"

      create_todo!('signing_doc', user&.id, title, @admin_signing_doc_url)
      mail(to: user.email, subject: title)
    end

    # 駁回通知
    def reject(rec)
      @rec = rec
      doc = rec.stage&.doc
      @admin_search_doc_url = send(Larvata::Signing.admin_search_doc_url, doc&.id)
      user = doc&.applicant
      title = "您的「#{doc&.title}」簽核單被駁回了"

      create_todo!('notice', user&.id, title, @admin_search_doc_url)
      mail(to: user&.email, subject: title)
    end

    # 核准通知
    def approve(rec)
      @rec = rec
      doc = rec.stage&.doc
      @admin_search_doc_url = send(Larvata::Signing.admin_search_doc_url, doc&.id)
      user = doc&.applicant
      title = "您的「#{doc&.title}」已核准了"

      create_todo!('notice', user&.id, title, @admin_search_doc_url)
      mail(to: user&.email, subject: title)
    end

    private

    def create_todo!(typing, user_id, title, url)
      Larvata::Signing::Todo.create!(typing: typing, user_id: user_id, title: title, url: url)
    end
  end
end
