require "larvata/signing/engine"

module Larvata
  module Signing
    # 取得指定簽核流程資料結構，並放入簽核單內
    def pull_flow(flow_id)
      flow = Larvata::Signing::Flow.includes(flow_stages: :flow_members).find_by_id(flow_id)

      doc = Larvata::Signing::Doc.new(flow.attributes.slice(:remind_period).merge({"larvata_signing_flow_id" => flow_id}))
      flow.flow_stages.each do |flow_stage|
        stage = doc.stages.build(flow_stage.attributes.slice(:typing, :seq))
        flow_stage.flow_members.each do |flow_member|
          stage.records.build(flow_member.attributes.slice(:dept_id, :role).merge({"signer_id" => flow_member.user_id}))
        end
      end

      doc
    end

    # 送出簽核結果，更新簽核紀錄
    # @param
    def sign(doc_id, signer_id, signed_result, remark)
    end
  end
end
