# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkVersion do
  subject(:work_version) do
    build(:work_version, :with_authors, :with_related_links, :with_related_works)
  end

  it 'has many contributors' do
    expect(work_version.contributors).to all(be_a(Contributor))
  end

  it 'has many related links' do
    expect(work_version.related_links).to all(be_a(RelatedLink))
  end

  it 'has many related works' do
    expect(work_version.related_works).to all(be_a(RelatedWork))
  end

  describe 'authors' do
    let(:work) { create(:work) }
    let(:work_version) { create(:work_version, work:) }

    before do
      allow(work_version.work).to receive(:broadcast_update)
      work_version.authors.create([
                                    { contributor_type: 'person', role: 'Author', 'first_name' => 'John',
                                      'last_name' => 'Lennon', 'weight' => '1' },
                                    { contributor_type: 'person', role: 'Author', 'first_name' => 'Ringo',
                                      'last_name' => 'Starr', 'weight' => '0' }
                                  ])
    end

    it 'orders by weight' do
      expect(work_version.authors.pluck(:last_name)).to eq %w[Starr Lennon]
    end
  end

  describe '#updatable?' do
    subject { work_version.updatable? }

    context 'when depositing' do
      let(:work_version) { build(:work_version, :depositing) }

      it { is_expected.to be false }
    end

    context 'when deposited' do
      let(:work_version) { build(:work_version, :deposited) }

      it { is_expected.to be true }
    end

    context 'when a draft' do
      let(:work_version) { build(:work_version, :version_draft) }

      it { is_expected.to be true }
    end
  end

  describe '#previous_version' do
    let(:work_version) { build(:work_version, :with_work) }

    context 'when no previous version' do
      it 'returns nil' do
        expect(work_version.previous_version).to be_nil
      end
    end

    context 'with previous version' do
      let(:work_version_v2) { build(:work_version, :deposited, :with_work, version: 2) }
      let(:work) { work_version.work }

      before { work.work_versions << work_version_v2 }

      it 'returns the previous version' do
        expect(work_version_v2.previous_version).to eq work_version
      end
    end
  end

  describe '#attached_files' do
    before do
      create(:attached_file, :with_file, work_version:)
    end

    it 'has attached files' do
      expect(work_version.attached_files).to be_present
    end
  end

  it 'has many contact emails' do
    expect(work_version.contact_emails).to all(be_a(ContactEmail))
  end

  describe '.awaiting_review_by' do
    subject { described_class.awaiting_review_by(user) }

    let(:work1) { create(:work, collection:) }
    let!(:work_version1) { create(:work_version, :pending_approval, work: work1) }
    let(:work2) { create(:work, collection:) }

    before do
      # We should not see this draft work in the query results
      create(:work_version, :first_draft, work: work2)
    end

    context 'when the user is a reviewer' do
      let(:collection) { create(:collection, :with_reviewers, :with_managers) }
      let(:user) { collection.reviewed_by.first }

      it { is_expected.to eq [work_version1] }
    end

    context 'when the user is a manager' do
      let(:collection) { create(:collection, :with_reviewers, :with_managers) }
      let(:user) { collection.managed_by.first }

      it { is_expected.to eq [work_version1] }
    end

    context 'when the user is an unrelated user' do
      let(:collection) { create(:collection, :with_managers) }
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end

  describe 'created_edtf' do
    describe 'validation' do
      subject(:work_version) { build(:work_version, created_edtf: date_string) }

      context 'with non-EDTF value' do
        let(:date_string) { 'foo bar' }

        it 'raises a type error' do
          expect { work_version }.to raise_error TypeError
        end
      end

      context 'with EDTF value' do
        let(:date_string) { EDTF.parse('2019-04-04') }

        it { is_expected.to be_valid }
      end
    end

    describe 'serialization' do
      subject(:work_version) { build(:work_version, created_edtf: date) }

      context 'with a single point' do
        let(:date) { EDTF.parse('2020-11') }

        it 'records an EDTF string' do
          expect(work_version.created_edtf.to_edtf).to eq '2020-11'
        end
      end

      context 'with an interval' do
        let(:date) { EDTF.parse('2020-11/2021') }

        it 'records an EDTF string' do
          expect(work_version.created_edtf.to_s).to eq '2020-11/2021'
        end
      end
    end
  end

  describe 'published_edtf' do
    describe 'serialization' do
      subject(:work_version) { build(:work_version, published_edtf: date) }

      context 'with a single point' do
        let(:date) { EDTF.parse('2020-11') }

        it 'records an EDTF string' do
          expect(work_version.published_edtf.to_edtf).to eq '2020-11'
        end
      end

      context 'with an interval' do
        let(:date) { EDTF.parse('2020-11/2021') }

        it 'records an EDTF string' do
          expect(work_version.published_edtf.to_s).to eq '2020-11/2021'
        end
      end
    end
  end

  describe 'license validation' do
    context 'with a nil license' do
      let(:work_version) { build(:work_version, license: nil) }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a blank license' do
      let(:work_version) { build(:work_version, license: '') }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a bogus license' do
      let(:work_version) { build(:work_version, license: 'Steal all my stuff') }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a valid selectable license' do
      let(:work_version) { build(:work_version, license: License.license_list.first) }

      it 'validates' do
        expect(work_version).to be_valid
      end
    end

    context 'with a valid displayable license' do
      let(:work_version) { build(:work_version, license: License.license_list(include_displayable: true).last) }

      it 'validates' do
        expect(work_version).to be_valid
      end
    end
  end

  describe 'type and subtype validation' do
    context 'with an empty work type' do
      let(:work_version) { build(:work_version, work_type: nil) }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a missing work type' do
      let(:work_version) { build(:work_version, work_type: 'a pile of something') }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a work_type that requires a user-supplied subtype and is empty' do
      let(:work_version) { build(:work_version, work_type: 'other', subtype: []) }

      it 'does not validate' do
        expect(work_version).not_to be_valid
      end
    end

    context 'with a work_type that requires a user-supplied subtype and is present' do
      let(:work_version) { build(:work_version, work_type: 'other', subtype: ['Pill bottle']) }

      it 'does not validate' do
        expect(work_version).to be_valid
      end
    end

    context 'with a work_type and a primary subtype' do
      let(:work_version) { build(:work_version, work_type: 'data', subtype: ['Database']) }

      it 'validates' do
        expect(work_version).to be_valid
      end
    end

    context 'with a work_type and a "more" subtype' do
      let(:work_version) { build(:work_version, work_type: 'data', subtype: ['Essay']) }

      it 'validates' do
        expect(work_version).to be_valid
      end
    end
  end

  describe 'access field' do
    it 'defaults to world' do
      expect(work_version.access).to eq('world')
    end

    context 'with value present in enum' do
      let(:access) { 'stanford' }

      it 'is valid' do
        work_version.access = access
        expect(work_version).to be_valid
      end
    end

    context 'with value absent from enum' do
      let(:access) { 'rutgers' }

      it 'raises ArgumentError' do
        expect do
          work_version.access = access
        end.to raise_error(ArgumentError, /'#{access}' is not a valid access/)
      end
    end
  end

  describe 'state machine flow' do
    before do
      allow(work_version.work).to receive(:broadcast_update)
    end

    it 'starts in first draft' do
      expect(work_version.state).to eq('first_draft')
    end

    describe 'a begin_deposit event' do
      before do
        allow(DepositJob).to receive(:perform_later)
        allow(Repository).to receive(:valid_version?).and_return(true)
        work_version.save!
      end

      it 'transitions from first_draft to depositing' do
        expect { work_version.begin_deposit! }
          .to change(work_version, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
        expect(DepositJob).to have_received(:perform_later).with(work_version)
        expect(work_version.reload.published_at).to be_a ActiveSupport::TimeWithZone
        expect(Repository).not_to have_received(:valid_version?)
      end

      context 'with pending_approval on a work' do
        let(:work_version) { create(:work_version, :pending_approval) }

        it 'transitions to depositing' do
          expect { work_version.begin_deposit! }
            .to change(work_version, :state)
            .to('depositing')
            .and change(Event, :count).by(1)
          expect(DepositJob).to have_received(:perform_later).with(work_version)
        end
      end

      context 'when version_draft' do
        let(:work_version) { create(:work_version, :version_draft) }

        let(:druid) { 'druid:bb652bq1296' }
        let(:cocina_obj) { instance_double(Cocina::Models::DRO, version: 1) }

        before do
          work_version.work.druid = druid
          allow(SdrClient::Find).to receive(:run).and_return(cocina_obj)
        end

        context 'when valid version' do
          it 'transitions from version_draft to depositing' do
            expect { work_version.begin_deposit! }
              .to change(work_version, :state)
              .to('depositing')
              .and change(Event, :count).by(1)
            expect(DepositJob).to have_received(:perform_later).with(work_version)
            expect(work_version.reload.published_at).to be_a ActiveSupport::TimeWithZone
            expect(Repository).to have_received(:valid_version?).with(druid:, h2_version: 1)
          end
        end

        context 'when invalid version' do
          before do
            allow(Repository).to receive(:valid_version?).and_return(false)
          end

          it 'does not transition' do
            expect { work_version.begin_deposit! }
              .to raise_error(StateMachines::InvalidTransition)
            expect(DepositJob).not_to have_received(:perform_later).with(work_version)
            expect(Repository).to have_received(:valid_version?)
          end
        end
      end
    end

    describe 'an update_metadata event' do
      let(:collection) { create(:collection, :with_managers) }
      let(:collection_version) { create(:collection_version_with_collection, collection:) }
      let(:work_version) { create(:work_version, state:, work:) }
      let(:work) { create(:work, collection:, depositor: collection.managed_by.first) }

      context 'when the state was new' do
        let(:state) { 'new' }

        it 'transitions to version draft' do
          expect { work_version.update_metadata! }
            .to change(work_version, :state)
            .from('new').to('first_draft')
            .and change(Event, :count).by(1)
                                      .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                                             'CollectionsMailer', 'first_draft_created', 'deliver_now',
                                             { params: {
                                               user: collection.managed_by.last,
                                               owner: work.owner,
                                               collection_version:
                                             }, args: [] }
                                           ))
        end
      end

      context 'when the state is pending_approval' do
        let(:work_version) { create(:work_version, :pending_approval) }

        it 'does not transition the state' do
          work_version.update_metadata!
          expect(work_version.state).to eq 'pending_approval'
        end
      end
    end

    describe 'a deposit_complete event' do
      let(:work_version) { build(:work_version, :depositing, work:) }
      let(:work) { create(:work, collection:, druid: 'druid:foo') }

      context 'when an initial deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'deposited_email', 'deliver_now',
                   { params: { user: work.owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when a deposit with globus' do
        let(:work_version) { build(:work_version, :depositing, work:, globus: true) }
        let(:collection) { create(:collection) }

        before do
          allow(Settings).to receive(:notify_admin_list).and_return(true)
        end

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'deposited_email', 'deliver_now',
                   { params: { user: work.owner, work_version: }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'globus_deposited_email', 'deliver_now',
                   { params: { user: work.owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when an subsequent version deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }
        let(:work_version) { build(:work_version, :depositing, version: 2, work:) }
        let(:work) { create(:work, collection:, druid: 'druid:foo') }

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'new_version_deposited_email', 'deliver_now',
                   { params: { user: work.owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when in a reviewed collection' do
        let(:collection) { create(:collection, :with_reviewers) }

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'approved_email', 'deliver_now',
                   { params: { user: work.owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end
    end

    describe 'a submit_for_review event' do
      let(:collection) { build(:collection, reviewed_by: [depositor, reviewer]) }
      let(:depositor) { build(:user) }
      let(:owner) { build(:user) }
      let(:reviewer) { build(:user) }

      context 'when work is first_draft' do
        let(:work_version) { create(:work_version, :first_draft, work:) }
        let(:work) { create(:work, collection:, depositor:, owner:) }

        it 'transitions to pending_approval' do
          expect { work_version.submit_for_review! }
            .to change(work_version, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work_version: }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when work was rejected' do
        let(:work_version) { create(:work_version, :rejected, work:) }
        let(:work) { create(:work, collection:, depositor:, owner:) }

        it 'transitions to pending_approval' do
          expect { work_version.submit_for_review! }
            .to change(work_version, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work_version: }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: owner, work_version: }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end
    end

    describe 'a reject event' do
      let(:work_version) { create(:work_version, :pending_approval, work:) }
      let(:work) { create(:work) }

      it 'transitions to rejected' do
        expect { work_version.reject! }
          .to change(work_version, :state)
          .to('rejected')
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                 'WorksMailer', 'reject_email', 'deliver_now',
                 { params: { user: work.owner, work_version: }, args: [] }
               ))
      end
    end

    describe 'a decommission event' do
      let(:collection) { create(:collection, :with_managers) }
      let(:work) { create(:work, collection:) }
      let(:work_version) { create(:work_version, work:) }

      it 'transitions to decommissioned' do
        expect { work_version.decommission! }
          .to change(work_version, :state)
          .to('decommissioned')
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                 'WorksMailer', 'decommission_owner_email', 'deliver_now',
                 { params: { work_version: }, args: [] }
               ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                 'WorksMailer', 'decommission_manager_email', 'deliver_now',
                 { params: { work_version:, user: collection.managed_by.first }, args: [] }
               ))
      end
    end
  end
end
