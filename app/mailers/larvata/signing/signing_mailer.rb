module Larvata::Signing
  class SigningMailer < ApplicationMailer
    include Rails.application.routes.url_helpers

    # 簽核通知
    def signing(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      user = rec.signer
      title = "「#{rec.stage&.doc&.title}」需要您簽核"

      create_todo!('signing_doc', user&.id, title, @admin_doc_url)
      mail(to: user.email, subject: title)
    end

    # 駁回通知
    def reject(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      user = rec.stage&.doc&.applicant
      title = "您的「#{rec.stage&.doc&.resource&.name}」簽核單被駁回了"

      create_todo!('notice', user&.id, title, @admin_doc_url)
      mail(to: user&.email, subject: title)
    end

    # 核准通知
    def approve(rec)
      @rec = rec
      @admin_doc_url = send(Larvata::Signing.admin_doc_url, @rec.stage&.doc&.id)
      user = rec.stage&.doc&.applicant
      title = "您的「#{rec.stage&.doc&.resource&.name}」已核准了"

      create_todo!('notice', user&.id, title, @admin_doc_url)
      mail(to: user&.email, subject: title)
    end

    private

    def create_todo!(typing, user_id, title, url)
      Larvata::Signing::Todo.create!(typing: typing, user_id: user_id, title: title, url: url)
    end
  end
end
