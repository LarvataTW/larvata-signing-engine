require 'rails_helper'

describe Larvata::Signing::Doc do 
  let!(:applicant) { create(:applicant_user) }
  let!(:supervisor) { create(:supervisor_user) }
  let!(:construction_manager) { create(:construction_manager_user) }
  let!(:sales_manager) { create(:sales_manager_user) }
  let!(:financial_manager) { create(:financial_manager_user) }
  let!(:president) { create(:president_user) }
  let(:inquirement_resource) { create(:inquirement_resource) }
  let(:flow) { create(:inquirement_flow, :with_resources, :with_flow_stages) }
  let(:doc) { create(:inquirement_doc, :with_resource_records, :with_stages, larvata_signing_resource_id: inquirement_resource.id) }

  describe ".pull_flow" do
    context "with creating signing_doc" do
      subject(:doc_from_flow) {
        doc_from_flow = flow.class.pull_flow(flow.id, applicant)
        doc_from_flow.title = "#{flow.resources.first&.name}簽核"
        doc_from_flow.save
        doc_from_flow
      }

      it { expect(doc_from_flow.errors.full_messages.any?).to eq(false) }
    end
  end

  describe "#sign" do 
    context "in the first stage" do
      it "when supervisor approve" do 
        doc.sign(supervisor, :approve, "pass").reload

        first_stage = doc.stages.first
        first_stage_records = first_stage.records

        expect(first_stage.completed?).to eq(true)
        expect(first_stage_records.first.state).to eq("signed")
        expect(first_stage_records.first.signing_result).to eq("approved")
      end

      it "when supervisor reject" do 
        doc.sign(supervisor, :reject, "reject").reload

        first_stage = doc.stages.first
        first_stage_records = first_stage.records
        first_resource_record = doc.resource_records.first

        expect(first_stage.completed?).to eq(true)
        expect(first_stage_records.first.state).to eq("signed")
        expect(first_stage_records.first.signing_result).to eq("rejected")
        expect(first_resource_record.state).to eq("rejected")
        expect(first_resource_record.signing_resourceable.state).to eq("evaluated")
      end

      it "when non-supervisor sign" do 
        doc.sign(construction_manager, :approve, "pass")

        expect(doc.errors.full_messages.any?).to eq(true)
      end
    end

    context "in the second stage" do 
      context "when construction_manager approve" do 
        it "and sales_manager approve" do 

        end

        it "and sales_manager reject" do 

        end

        context "and sales_manager waiting for signing_result of financial_manager" do 
          it "sales_manager is waiting" do

          end

          it "financial_manager signing record created" do 

          end

          it "when financial_manager approve" do 

          end

          it "when financial_manager reject" do 

          end
        end
      end

      context "when someone reject" do 
        it "and choose return to the first stage" do 

        end

        it "and choose return to the applicant" do 

        end
      end
    end
  end
end


