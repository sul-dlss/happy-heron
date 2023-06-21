# frozen_string_literal: true

require "rails_helper"

# State machine specs are split into different file for clarity.
RSpec.describe WorkVersion do
  before do
    allow(work_version.work).to receive(:broadcast_update)
  end

  describe "a begin_deposit event" do
    let(:work_version) do
      build(:work_version, :with_authors, :with_related_links, :with_related_works)
    end

    before do
      allow(DepositJob).to receive(:perform_later)
      allow(Repository).to receive(:valid_version?).and_return(true)
      work_version.save!
    end

    it "transitions from first_draft to depositing" do
      expect { work_version.begin_deposit! }
        .to change(work_version, :state)
        .to("depositing")
        .and change(Event, :count).by(1)
      expect(DepositJob).to have_received(:perform_later).with(work_version)
      expect(work_version.reload.published_at).to be_a ActiveSupport::TimeWithZone
      expect(Repository).not_to have_received(:valid_version?)
    end

    context "with pending_approval on a work" do
      let(:work_version) { create(:work_version, :pending_approval) }

      it "transitions to depositing" do
        expect { work_version.begin_deposit! }
          .to change(work_version, :state)
          .to("depositing")
          .and change(Event, :count).by(1)
        expect(DepositJob).to have_received(:perform_later).with(work_version)
      end
    end

    context "when globus upload" do
      before do
        work_version.upload_type = "globus"
      end

      it "is able to transition to globus_setup_pending" do
        expect { work_version.globus_setup_pending! }
          .to change(work_version, :state)
          .from("first_draft").to("globus_setup_first_draft")
      end
    end

    context "when version_draft" do
      let(:work_version) { create(:work_version, :version_draft) }
      let(:druid) { "druid:bb652bq1296" }
      let(:cocina_obj) { instance_double(Cocina::Models::DRO, version: 1) }

      before do
        work_version.work.druid = druid
        allow(SdrClient::Find).to receive(:run).and_return(cocina_obj)
      end

      context "when valid version" do
        it "transitions from version_draft to depositing" do
          expect { work_version.begin_deposit! }
            .to change(work_version, :state)
            .to("depositing")
            .and change(Event, :count).by(1)
          expect(DepositJob).to have_received(:perform_later).with(work_version)
          expect(work_version.reload.published_at).to be_a ActiveSupport::TimeWithZone
          expect(Repository).to have_received(:valid_version?).with(druid:, h2_version: 1)
        end
      end

      context "when invalid version" do
        before do
          allow(Repository).to receive(:valid_version?).and_return(false)
        end

        it "does not transition" do
          expect { work_version.begin_deposit! }
            .to raise_error(StateMachines::InvalidTransition)
          expect(DepositJob).not_to have_received(:perform_later).with(work_version)
          expect(Repository).to have_received(:valid_version?)
        end
      end

      context "when globus upload" do
        before do
          work_version.upload_type = "globus"
        end

        it "is able to transition to globus_setup_pending" do
          expect { work_version.globus_setup_pending! }
            .to change(work_version, :state)
            .from("version_draft").to("globus_setup_version_draft")
        end
      end
    end
  end

  describe "pid_assigned event" do
    let(:collection) { create(:collection, :with_managers) }
    let(:collection_version) { create(:collection_version_with_collection, collection:) }
    let(:work_version) { create(:work_version, :depositing) }
    let(:work) { create(:work, collection:, depositor: collection.managed_by.first) }

    before do
      allow(DepositJob).to receive(:perform_later)
      allow(Repository).to receive(:valid_version?).and_return(true)
      work_version.work.druid = "druid:bb652bq1296"
    end

    it "does not trigger the after_depositing hook" do
      work_version.pid_assigned!
      expect(DepositJob).not_to have_received(:perform_later)
    end
  end

  describe "globus_setup_complete event" do
    let(:collection) { create(:collection, :with_managers) }
    let(:collection_version) { create(:collection_version_with_collection, collection:) }
    let(:work_version) { create(:work_version, state:, work:) }
    let(:work) { create(:work, collection:, depositor: collection.managed_by.first) }

    context "when the state was globus_setup_first_draft" do
      let(:state) { "globus_setup_first_draft" }

      it "transitions back to first_draft" do
        expect { work_version.globus_setup_complete! }
          .to change(work_version, :state)
          .from("globus_setup_first_draft").to("first_draft")
      end
    end

    context "when the state was globus_setup_version_draft" do
      let(:state) { "globus_setup_version_draft" }

      it "transitions back to version_draft" do
        expect { work_version.globus_setup_complete! }
          .to change(work_version, :state)
          .from("globus_setup_version_draft").to("version_draft")
      end
    end

    context "when the state was first_draft" do
      let(:state) { "first_draft" }

      it "stays on first_draft" do
        expect { work_version.globus_setup_complete! }
          .not_to change(work_version, :state)
      end
    end

    context "when the state was version_draft" do
      let(:state) { "version_draft" }

      it "stays on version_draft" do
        expect { work_version.globus_setup_complete! }
          .not_to change(work_version, :state)
      end
    end
  end

  describe "globus_setup_aborted event" do
    let(:collection) { create(:collection, :with_managers) }
    let(:collection_version) { create(:collection_version_with_collection, collection:) }
    let(:work_version) { create(:work_version, state:, work:) }
    let(:work) { create(:work, collection:, depositor: collection.managed_by.first) }

    context "when the state was globus_setup_first_draft" do
      let(:state) { "globus_setup_first_draft" }

      it "transitions back to first_draft" do
        expect { work_version.globus_setup_aborted! }
          .to change(work_version, :state)
          .from("globus_setup_first_draft").to("first_draft")
      end
    end

    context "when the state was globus_setup_version_draft" do
      let(:state) { "globus_setup_version_draft" }

      it "transitions back to version_draft" do
        expect { work_version.globus_setup_aborted! }
          .to change(work_version, :state)
          .from("globus_setup_version_draft").to("version_draft")
      end
    end
  end

  describe "an update_metadata event" do
    let(:collection) { create(:collection, :with_managers) }
    let(:collection_version) { create(:collection_version_with_collection, collection:) }
    let(:work_version) { create(:work_version, state:, work:, upload_type:) }
    let(:work) { create(:work, collection:, depositor: collection.managed_by.first) }
    let(:upload_type) { "browser" }

    context "when the state was new" do
      let(:state) { "new" }

      it "transitions to version draft" do
        expect { work_version.update_metadata! }
          .to change(work_version, :state)
          .from("new").to("first_draft")
          .and change(Event, :count).by(1)
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "CollectionsMailer", "first_draft_created", "deliver_now",
            {params: {
              user: collection.managed_by.last,
              owner: work.owner,
              work:,
              collection_version:
            }, args: []}
          ))
      end
    end

    context "when the state is pending_approval" do
      let(:state) { "pending_approval" }

      it "does not transition the state" do
        work_version.update_metadata!
        expect(work_version.state).to eq "pending_approval"
      end
    end

    context "when the state is globus_setup_first_draft" do
      let(:state) { "globus_setup_first_draft" }

      context "when upload type is browser" do
        it "transitions back to first_draft" do
          work_version.update_metadata!
          expect(work_version.state).to eq "first_draft"
        end
      end

      context "when upload type is globus" do
        let(:upload_type) { "globus" }

        it "allows the transition and retains the same state" do
          work_version.update_metadata!
          expect(work_version.state).to eq "globus_setup_first_draft"
        end
      end
    end

    context "when the state is globus_setup_version_draft" do
      let(:state) { "globus_setup_version_draft" }

      context "when upload type is browser" do
        it "transitions back to version_draft" do
          work_version.update_metadata!
          expect(work_version.state).to eq "version_draft"
        end
      end

      context "when upload type is globus" do
        let(:upload_type) { "globus" }

        it "allows the transition and retains the same state" do
          work_version.update_metadata!
          expect(work_version.state).to eq "globus_setup_version_draft"
        end
      end
    end
  end

  describe "a deposit_complete event" do
    let(:work_version) { build(:work_version, :depositing, work:) }
    let(:work) { create(:work, collection:, druid: "druid:foo") }

    context "when an initial deposit into a non-reviewed collection" do
      let(:collection) { create(:collection) }

      it "transitions to deposited" do
        expect { work_version.deposit_complete! }
          .to change(work_version, :state)
          .to("deposited")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "deposited_email", "deliver_now",
            {params: {user: work.owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end

    context "when a deposit with globus" do
      let(:work_version) do
        build(:work_version, :depositing, work:, upload_type: "browser", globus_endpoint: "/some/globus/url")
      end
      let(:collection) { create(:collection) }

      before do
        allow(Settings).to receive(:notify_admin_list).and_return(true)
      end

      it "transitions to deposited" do
        expect { work_version.deposit_complete! }
          .to change(work_version, :state)
          .to("deposited")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "deposited_email", "deliver_now",
            {params: {user: work.owner, work_version:}, args: []}
          ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "globus_deposited_email", "deliver_now",
            {params: {user: work.owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end

    context "when an subsequent version deposit into a non-reviewed collection" do
      let(:collection) { create(:collection) }
      let(:work_version) { build(:work_version, :depositing, version: 2, work:) }
      let(:work) { create(:work, collection:, druid: "druid:foo") }

      it "transitions to deposited" do
        expect { work_version.deposit_complete! }
          .to change(work_version, :state)
          .to("deposited")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "new_version_deposited_email", "deliver_now",
            {params: {user: work.owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end

    context "when in a reviewed collection" do
      let(:collection) { create(:collection, :with_reviewers) }

      it "transitions to deposited" do
        expect { work_version.deposit_complete! }
          .to change(work_version, :state)
          .to("deposited")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "approved_email", "deliver_now",
            {params: {user: work.owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end
  end

  describe "a submit_for_review event" do
    let(:collection) { build(:collection, reviewed_by: [depositor, reviewer]) }
    let(:depositor) { build(:user) }
    let(:owner) { build(:user) }
    let(:reviewer) { build(:user) }

    context "when work is first_draft" do
      let(:work_version) { create(:work_version, :first_draft, work:) }
      let(:work) { create(:work, collection:, depositor:, owner:) }

      it "transitions to pending_approval" do
        expect { work_version.submit_for_review! }
          .to change(work_version, :state)
          .to("pending_approval")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "ReviewersMailer", "submitted_email", "deliver_now",
            {params: {user: reviewer, work_version:}, args: []}
          ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "submitted_email", "deliver_now",
            {params: {user: owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end

    context "when work was rejected" do
      let(:work_version) { create(:work_version, :rejected, work:) }
      let(:work) { create(:work, collection:, depositor:, owner:) }

      it "transitions to pending_approval" do
        expect { work_version.submit_for_review! }
          .to change(work_version, :state)
          .to("pending_approval")
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "ReviewersMailer", "submitted_email", "deliver_now",
            {params: {user: reviewer, work_version:}, args: []}
          ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "submitted_email", "deliver_now",
            {params: {user: owner, work_version:}, args: []}
          ))
          .and change(Event, :count).by(1)
      end
    end
  end

  describe "a reject event" do
    let(:work_version) { create(:work_version, :pending_approval, work:) }
    let(:work) { create(:work) }

    it "transitions to rejected" do
      expect { work_version.reject! }
        .to change(work_version, :state)
        .to("rejected")
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "WorksMailer", "reject_email", "deliver_now",
          {params: {user: work.owner, work_version:}, args: []}
        ))
    end
  end

  describe "a decommission event" do
    let(:collection) { create(:collection, :with_managers) }
    let(:work) { create(:work, collection:) }
    let(:work_version) { create(:work_version, work:) }

    it "transitions to decommissioned" do
      expect { work_version.decommission! }
        .to change(work_version, :state)
        .to("decommissioned")
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "WorksMailer", "decommission_owner_email", "deliver_now",
          {params: {work_version:}, args: []}
        ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          "WorksMailer", "decommission_manager_email", "deliver_now",
          {params: {work_version:, user: collection.managed_by.first}, args: []}
        ))
    end
  end

  describe "unzip event" do
    let(:work_version) { create(:work_version) }

    it "transitions to unzip_first_draft" do
      expect { work_version.unzip! }
        .to change(work_version, :state)
        .to("unzip_first_draft")
        .and(have_enqueued_job(UnzipJob).with(work_version))
    end
  end

  describe "unzip_and_submit_for_review event" do
    let(:work_version) { create(:work_version, state: "pending_approval") }

    it "transitions to unzip_pending_approval" do
      expect { work_version.unzip_and_submit_for_review! }
        .to change(work_version, :state)
        .to("unzip_pending_approval")
        .and(have_enqueued_job(UnzipJob).with(work_version))
    end
  end

  describe "unzip_and_begin_deposit event" do
    let(:work_version) { create(:work_version) }

    it "transitions to unzip_depositing" do
      expect { work_version.unzip_and_begin_deposit! }
        .to change(work_version, :state)
        .to("unzip_depositing")
        .and(have_enqueued_job(UnzipJob).with(work_version))
    end
  end

  describe "fetch globus event" do
    let(:work_version) { create(:work_version) }

    it "transitions to fetch_globus_first_draft" do
      expect { work_version.fetch_globus! }
        .to change(work_version, :state)
        .to("fetch_globus_first_draft")
        .and(have_enqueued_job(FetchGlobusJob).with(work_version))
    end
  end

  describe "fetch_globus_and_submit_for_review event" do
    let(:work_version) { create(:work_version, state: "pending_approval") }

    it "transitions to fetch_globus_pending_approval" do
      expect { work_version.fetch_globus_and_submit_for_review! }
        .to change(work_version, :state)
        .to("fetch_globus_pending_approval")
        .and(have_enqueued_job(FetchGlobusJob).with(work_version))
    end
  end

  describe "fetch_globus_and_begin_deposit event" do
    let(:work_version) { create(:work_version) }

    it "transitions to fetch_globus_depositing" do
      expect { work_version.fetch_globus_and_begin_deposit! }
        .to change(work_version, :state)
        .to("fetch_globus_depositing")
        .and(have_enqueued_job(FetchGlobusJob).with(work_version))
    end
  end
end
