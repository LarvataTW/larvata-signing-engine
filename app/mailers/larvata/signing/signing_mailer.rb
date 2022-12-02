module Larvata::Signing
  class SigningMailer < ApplicationMailer
    include Rails.application.routes.url_helpers

    # 簽核通知
    # @param recs [Signing::Srecord] 或是 Signing::Doc 簽核紀錄或是簽核單，因為 recs 會排除掉簽核人員即申請人的情況
    def signing(recs)
      if recs.class.name != "Signing::Doc"
        recs.each do |rec|
          build_doc(rec)
          build_doc_urls
          build_title("[#{@doc&.title}] 需要您簽核")
          create_todo_and_send_email(rec&.signer)
        end
      end
    end

    # 駁回通知
    # @param recs [Signing::Srecord] 或是 Signing::Doc 簽核紀錄或是簽核單，因為 recs 會排除掉簽核人員即申請人的情況
    def reject(recs)
      if recs.class.name == "Signing::Doc"
        @doc = recs
        build_applicant
        build_doc_urls
        build_title("[#{@doc&.title}] 被駁回了")
      else
        recs.each do |rec|
          build_doc(rec)
          build_applicant
          build_doc_urls
          build_title("[#{@doc&.title}] 被駁回了")
          create_todo_and_send_email(rec&.signer)
        end
      end

      create_todo_and_send_email(@applicant)
    end

    # 核准通知
    # @param recs [Signing::Srecord] 或是 Signing::Doc 簽核紀錄或是簽核單，因為 recs 會排除掉簽核人員即申請人的情況
    def approve(recs)
      if recs.class.name == "Signing::Doc"
        @doc = recs
        build_applicant
        build_doc_urls
        build_title("[#{@doc&.title}] 已核准了")
      else
        recs.each do |rec|
          build_doc(rec)
          build_applicant
          build_doc_urls
          build_title("[#{@doc&.title}] 已核准了")
          create_todo_and_send_email(rec&.signer)
        end
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
