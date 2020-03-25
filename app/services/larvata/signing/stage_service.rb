module Larvata
  module Signing
    module StageService
      # 是否為該簽核單的最後階段?
      def is_first?
        doc.stages.order(:seq).first&.id == id
      end

      # 是否為該簽核單的最後階段?
      def is_last?
        doc.stages.order(:seq).last&.id == id
      end

      # 取得下一階段
      def next_stage
        self.class.pending
          .where(larvata_signing_doc_id: larvata_signing_doc_id)
          .order(:seq)
          .first
      end

      # 同一階段內，是否沒有尚未簽核的資料
      def has_no_signed_srecord?
        has_not_yet_signed.size == 0
      end

      # 取得同一階段內尚未簽核的紀錄
      def has_not_yet_signed
        srecords.where(signing_result: nil)
      end

      # 添加新階段到指定階段後
      def append_to!(current_stage)
        Larvata::Signing::Stage
          .where(larvata_signing_doc_id: larvata_signing_doc_id)
          .where("seq > ?", current_stage&.seq || 0)
          .update_all("seq = seq + 1")

        self.seq = current_stage.seq + 1
        self.save!
      end

      private

      def set_default_values
        self.state ||= "pending"
        self.seq ||= 1
      end
    end
  end
end
