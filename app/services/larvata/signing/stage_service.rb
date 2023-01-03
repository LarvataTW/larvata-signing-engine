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
      # 添加的新階段要在加簽階段後
      def append_to!(current_stage)
        # 找到目前階段的下一個階段資料，排除掉加簽階段
        target_stage = Larvata::Signing::Stage
          .select('id, seq')
          .where(larvata_signing_doc_id: larvata_signing_doc_id)
          .where("seq > ?", current_stage&.seq || 0)
          .where("state = ?", "pending")
          .first

        Larvata::Signing::Stage
          .where(larvata_signing_doc_id: larvata_signing_doc_id)
          .where("seq >= ?", target_stage.seq)
          .update_all("seq = seq + 1")

        self.seq = target_stage.seq
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
