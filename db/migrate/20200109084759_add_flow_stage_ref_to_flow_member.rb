class AddFlowStageRefToFlowMember < ActiveRecord::Migration[5.1]
  def change
    add_reference :larvata_signing_flow_members, :larvata_signing_flow_stage, foreign_key: true, index: {name: 'index_larvata_signing_flow_members_on_flow_stage_id'}
  end
end
