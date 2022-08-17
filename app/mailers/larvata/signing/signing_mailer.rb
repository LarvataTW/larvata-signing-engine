module Larvata::Signing
  class SigningMailer < ApplicationMailer
    include Rails.application.routes.url_helpers

    # 簽核通知
    def signing(recs)
      recs.each do |rec|
        build_doc(rec)
        build_doc_urls
        build_title("[#{@doc&.title}] 需要您簽核")
        create_todo_and_send_email(rec&.signer)
      end
    end

    # 駁回通知
    def reject(recs)
      recs.each do |rec|
        build_doc(rec)
        build_applicant
        build_doc_urls
        build_title("[#{@doc&.title}] 被駁回了")
        create_todo_and_send_email(rec&.signer)
      end

      create_todo_and_send_email(@applicant)
    end

    # 核准通知
    def approve(recs)
      recs.each do |rec|
        build_doc(rec)
        build_applicant
        build_doc_urls
        build_title("[#{@doc&.title}] 已核准了")
        create_todo_and_send_email(rec&.signer)
      end

      create_todo_and_send_email(@applicant)
    end

    private

      def build_doc(rec)
        @doc ||= rec&.stage&.doc
      end

      def build_applicant
        @applicant ||= @doc&.applicant
      end

      def build_doc_urls
        @admin_search_doc_url ||= send(Larvata::Signing.admin_search_doc_url, @doc&.id)
        @admin_signing_doc_url ||= send(Larvata::Signing.admin_signing_doc_url, @doc&.id)
      end

      def build_title(title)
        @title ||= title
      end

      def create_todo!(typing, user_id, title, url)
        Larvata::Signing::Todo.create!(typing: typing, user_id: user_id, title: title, url: url)
      end

      def create_todo_and_send_email(user)
        @user = user
        create_todo!('notice', user&.id, @title, @admin_search_doc_url)
        mail(to: user&.email, subject: @title)
      end
  end
end
