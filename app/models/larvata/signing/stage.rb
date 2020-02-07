module Larvata::Signing
  class Stage < ApplicationRecord
    TYPINGS = [:sign, :counter_sign, :any_supervisor, :inform]
    STATES = [:pending, :signing, :completed]

    enum typing: TYPINGS
    enum state: STATES

    belongs_to :doc, class_name: "Larvata::Signing::Doc", 
      foreign_key: "larvata_signing_doc_id", optional: true

    has_many :records, class_name: "Larvata::Signing::Record", 
      foreign_key: "larvata_signing_stage_id", inverse_of: :stage

    before_create :set_default_values

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
    def has_no_signed_record?
      has_not_yet_signed(stage&.id).size == 0
    end

    # 取得同一階段內尚未簽核的紀錄
    def has_not_yet_signed(stage_id)
      records.where(signing_result: nil)
    end

    private

    def set_default_values
      self.countersign ||= false
      self.state ||= "pending"
    end
  end
end
