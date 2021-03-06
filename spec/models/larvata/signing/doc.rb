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
  let(:doc) { 
    create(:inquirement_doc, :with_resource_records, :with_stages, 
           larvata_signing_resource_id: inquirement_resource.id, 
           applicant_id: applicant.id
          ) 
  }
  let(:first_resource_record) { doc.resource_records.first }
  let(:second_resource_record) { doc.resource_records.second }
  let(:third_resource_record) { doc.resource_records.third }
  let(:first_stage) { doc.stages.first }
  let(:first_stage_srecords) { doc.stages.first.srecords }
  let(:second_stage) { doc.stages.second }
  let(:second_stage_srecords) { doc.stages.second.srecords }
  let(:third_stage) { doc.stages.third }
  let(:third_stage_srecords) { doc.stages.third.srecords }
  let(:fourth_stage) { doc.stages.fourth }
  let(:fourth_stage_srecords) { doc.stages.fourth.srecords }
  let(:todo_count) { Larvata::Signing::Todo.count }

  subject(:begin_signing) {
    doc.commit!
  }

  before {
    Cleaner.clean_messages
  }

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

  describe "#commit!" do
    it "begin signing" do
      begin_signing

      expect(doc.reload.state).to eq("signing")
      expect(first_stage.reload.state).to eq("signing")
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(todo_count).to eq(1)
    end
  end

  describe "#sign" do 
    context "when doc state is not signing" do
      it "will get doc errors" do 
        doc.sign(supervisor, :approve, "pass")

        expect(doc.errors.full_messages.any?).to eq(true)
      end
    end

    context "in the first stage" do
      before {
        begin_signing
        Cleaner.clean_messages
      }

      it "when supervisor approve" do 
        doc.sign(supervisor, :approve, "pass")

        expect(first_stage.reload.completed?).to eq(true)
        expect(first_stage_srecords.reload.first.state).to eq("signed")
        expect(first_stage_srecords.reload.first.signing_result).to eq("approved")
        expect(ActionMailer::Base.deliveries.count).to eq(2)
        expect(todo_count).to eq(2)
      end

      it "when supervisor reject" do 
        doc.sign(supervisor, :reject, "reject")

        expect(first_stage.reload.completed?).to eq(true)
        expect(first_stage_srecords.first.reload.state).to eq("signed")
        expect(first_stage_srecords.first.reload.signing_result).to eq("rejected")
        expect(first_resource_record.reload.state).to eq("rejected")
        expect(first_resource_record.signing_resourceable.reload.state).to eq("evaluated")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(todo_count).to eq(1)
      end

      it "when non-supervisor sign" do 
        doc.sign(construction_manager, :approve, "pass")

        expect(doc.errors.full_messages.any?).to eq(true)
      end
    end

    context "in the second stage" do 
      context "when construction_manager approve" do 
        subject(:doc_with_second_stage_signing_and_construction_manager_approved) { 
          doc.commit!
          doc.sign(supervisor, :approve, "pass")
          doc.sign(construction_manager, :approve, "pass")

          Cleaner.clean_messages

          doc
        }

        it "and sales_manager approve" do 
          doc = doc_with_second_stage_signing_and_construction_manager_approved
          doc.sign(sales_manager, :approve, "pass")

          expect(second_stage.reload.completed?).to eq(true)
          expect(second_stage_srecords.second.reload.state).to eq("signed")
          expect(second_stage_srecords.second.reload.signing_result).to eq("approved")
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(todo_count).to eq(1)
        end

        it "and sales_manager reject" do 
          doc = doc_with_second_stage_signing_and_construction_manager_approved
          doc.sign(sales_manager, :reject, "reject")

          expect(second_stage.reload.completed?).to eq(true)
          expect(second_stage_srecords.first.reload.state).to eq("signed")
          expect(second_stage_srecords.first.reload.signing_result).to eq("rejected")
          expect(second_resource_record.reload.state).to eq("rejected")
          expect(second_resource_record.signing_resourceable.reload.state).to eq("evaluated")
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(todo_count).to eq(1)
        end

        it "and sales_manager reject and return to first stage" do 
          doc = doc_with_second_stage_signing_and_construction_manager_approved
          doc.sign(sales_manager, :reject, "reject", return_stage_seq: first_stage.seq)

          expect(first_stage.reload.signing?).to eq(true)
          expect(second_stage.reload.pending?).to eq(true)
          expect(first_stage_srecords.reload.count).to eq(2)
          expect(second_stage_srecords.reload.count).to eq(4)
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(todo_count).to eq(1)
        end

        context "and sales_manager approve and waiting for signing_result of financial_manager" do 
          subject(:waiting_for_financial_manager_signing) {
            doc = doc_with_second_stage_signing_and_construction_manager_approved
            doc.sign(sales_manager, :approve, "waiting for financial_manager signing", waiting_stage_typing: 'sign', waiting_signer_ids: financial_manager.id.to_s)
            doc
          }

          it "financial_manager signing srecord created" do 
            waiting_for_financial_manager_signing

            expect(second_stage_srecords.reload.count).to eq(2)
            expect(Larvata::Signing::Srecord.last.signer_id).to eq(financial_manager.id)
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(todo_count).to eq(1)
          end

          it "when financial_manager approve" do 
            doc = waiting_for_financial_manager_signing

            Cleaner.clean_messages

            doc.sign(financial_manager, :approve, "pass")

            expect(second_stage_srecords.reload.count).to eq(2)
            expect(second_stage.reload.completed?).to eq(true)
            expect(third_stage.reload.completed?).to eq(true)
            expect(fourth_stage.reload.signing?).to eq(true)
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(todo_count).to eq(1)
          end
        end

        context "and sales_manager waiting for signing_result of financial_manager" do 
          subject(:waiting_for_financial_manager_signing) {
            doc = doc_with_second_stage_signing_and_construction_manager_approved
            doc.sign(sales_manager, :wait, "waiting for financial_manager signing", waiting_stage_typing: 'sign', waiting_signer_ids: financial_manager.id.to_s)
            doc
          }

          it "financial_manager signing srecord created" do 
            waiting_for_financial_manager_signing

            expect(second_stage_srecords.reload.count).to eq(2)
            expect(Larvata::Signing::Srecord.last.signer_id).to eq(financial_manager.id)
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(todo_count).to eq(1)
          end

          it "when financial_manager approve" do 
            doc = waiting_for_financial_manager_signing

            Cleaner.clean_messages

            doc.sign(financial_manager, :approve, "pass")

            expect(second_stage.reload.signing?).to eq(true)
            expect(second_stage_srecords.reload.count).to eq(3)
            expect(second_stage_srecords.last.reload.signer_id).to eq(sales_manager.id)
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(todo_count).to eq(1)
          end

          it "when financial_manager reject" do 
            doc = waiting_for_financial_manager_signing

            Cleaner.clean_messages

            doc.sign(financial_manager, :reject, "reject")

            expect(second_stage.reload.pending?).to eq(true)
            expect(Larvata::Signing::Srecord.last.reload.state).to eq("signed")
            expect(Larvata::Signing::Srecord.last.reload.signing_result).to eq("rejected")
            expect(first_resource_record.reload.state).to eq("rejected")
            expect(first_resource_record.signing_resourceable.reload.state).to eq("evaluated")
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(todo_count).to eq(1)
          end
        end
      end
    end

    context "in the third stage" do
      subject(:doc_with_third_stage_signing) { 
        doc.commit!
        doc.sign(supervisor, :approve, "pass")
        doc.sign(construction_manager, :approve, "pass")
        doc.sign(sales_manager, :approve, "pass")

        Cleaner.clean_messages

        doc
      }

      it "when president approve" do 
        doc = doc_with_third_stage_signing
        doc.sign(president, :approve, "pass", implement_resource_record_id: first_resource_record.signing_resourceable.id)

        expect(doc.state).to eq("approved")
        expect(first_resource_record.reload.state).to eq("implement")
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(doc.srecords.last.implement_id).to eq(first_resource_record.signing_resourceable.id)
        expect(todo_count).to eq(1)
      end
    end
  end
end
