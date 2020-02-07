class RemoveLarvataSigningStageIdFromLarvataSigningFlowMember < ActiveRecord::Migration[5.1]
  def change
    remove_index :larvata_signing_flow_members, :larvata_signing_stage_id
    remove_column :larvata_signing_flow_members, :larvata_signing_stage_id, :bigint
  end
end
