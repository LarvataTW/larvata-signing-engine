module Larvata::Signing
  class Flow < ApplicationRecord
    has_many :resources, class_name: "Larvata::Signing::Resource", 
      foreign_key: "larvata_signing_flow_id"

    has_many :flow_stages, class_name: "Larvata::Signing::FlowStage", 
      foreign_key: "larvata_signing_flow_id"

    # 取得指定簽核流程資料結構，並放入簽核單內
    def self.pull_flow(flow_id, current_user)
      flow = Larvata::Signing::Flow.includes(flow_stages: :flow_members).find_by_id(flow_id)

      doc = Larvata::Signing::Doc.new(flow.attributes.slice("remind_period").merge({"larvata_signing_flow_id" => flow_id}))
      flow.flow_stages.each do |flow_stage|
        stage = doc.stages.build(flow_stage.attributes.slice("typing", "seq"))

        unless flow_stage.supervisor_sign?
          flow_stage.flow_members.each do |flow_member|
            stage.srecords.build(flow_member.attributes.slice("dept_id", "role").merge({"signer_id" => flow_member.user_id}))
          end
        else
          # TBD 建立主管簽核資料
        end
      end

      doc
    end
  end
end
