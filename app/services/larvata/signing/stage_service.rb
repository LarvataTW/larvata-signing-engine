module Larvata
  module Signing
    module StageService
      # 是否為該簽核單的最後階段?
      def is_first?
        doc.stages.first&.id == id
      end

      # 是否為該簽核單的最後階段?
      def is_last?
        doc.stages.last&.id == id
      end

      # 取得下一階段
      def next_stage
        self.class.where("seq > ?", seq).order("seq ASC").first
      end

      # 同一階段內，是否沒有尚未簽核的資料
      def has_no_signed_srecord?
        has_not_yet_signed.size == 0
      end

      # 取得同一階段內尚未簽核的紀錄
      def has_not_yet_signed
        srecords.where(signing_result: nil)
      end

      private

      def set_default_values
        self.countersign ||= false
        self.state ||= "pending"
      end
    end
  end
end
