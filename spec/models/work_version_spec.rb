# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkVersion do
  subject(:work_version) { build(:work_version, :with_authors, :with_related_links, :with_related_works, :with_attached_file) }

  it 'has many contributors' do
    expect(work_version.contributors).to all(be_a(Contributor))
  end

  it 'has many related links' do
    expect(work_version.related_links).to all(be_a(RelatedLink))
  end

  it 'has many related works' do
    expect(work_version.related_works).to all(be_a(RelatedWork))
  end

  it 'has attached files' do
    expect(work_version.attached_files).to be_present
  end

  it 'has many contact emails' do
    expect(work_version.contact_emails).to all(be_a(ContactEmail))
  end

  describe '.awaiting_review_by' do
    subject { described_class.awaiting_review_by(user) }

    let(:work) { create(:work, :pending_approval, collection: collection) }

    context 'when the user is a reviewer' do
      let(:collection) { create(:collection, :with_reviewers) }
      let(:user) { collection.reviewed_by.first }

      it { is_expected.to include(work) }
    end

    context 'when the user is a manager' do
      let(:collection) { create(:collection, :with_managers) }
      let(:user) { collection.managed_by.first }

      it { is_expected.to include(work) }
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
    context 'with an empty license' do
      let(:work_version) { build(:work_version, license: nil) }

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

    context 'with a valid license' do
      let(:work_version) { build(:work_version, license: License.license_list.first) }

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
        work_version.update(access: access)
        expect(work_version).to be_valid
      end
    end

    context 'with value absent from enum' do
      let(:access) { 'rutgers' }

      it 'raises ArgumentError' do
        expect { work_version.update(access: access) }.to raise_error(ArgumentError, /'#{access}' is not a valid access/)
      end
    end
  end

  describe 'state machine flow' do
    it 'starts in first draft' do
      expect(work_version.state).to eq('first_draft')
    end

    describe 'a begin_deposit event' do
      before do
        allow(DepositJob).to receive(:perform_later)
      end

      it 'transitions from first_draft to depositing' do
        expect { work_version.begin_deposit! }
          .to change(work_version, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
        expect(DepositJob).to have_received(:perform_later).with(work_version)
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
    end

    describe 'an update_metadata event' do
      let(:collection) { create(:collection, :with_managers) }
      let(:work_version) { create(:work_version, state: state, work: work) }
      let(:work) { create(:work, collection: collection, depositor: collection.managers.first) }

      context 'when the state was deposited' do
        let(:state) { 'deposited' }

        it 'transitions to version draft' do
          expect { work_version.update_metadata! }
            .to change(work_version, :state)
            .from('deposited').to('version_draft')
            .and change(Event, :count).by(1)
                                      .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                                             'CollectionsMailer', 'collection_activity', 'deliver_now',
                                             { params: {
                                               user: collection.managers.last,
                                               depositor: work.depositor,
                                               collection: collection
                                             }, args: [] }
                                           ))
        end
      end

      context 'when the state was new' do
        let(:state) { 'new' }

        it 'transitions to version draft' do
          expect { work_version.update_metadata! }
            .to change(work_version, :state)
            .from('new').to('first_draft')
            .and change(Event, :count).by(1)
                                      .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                                             'CollectionsMailer', 'collection_activity', 'deliver_now',
                                             { params: {
                                               user: collection.managers.last,
                                               depositor: work.depositor,
                                               collection: collection
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
      let(:work_version) { build(:work_version, :depositing, work: work) }
      let(:work) { create(:work, collection: collection, druid: 'druid:foo') }

      context 'when an initial deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'deposited_email', 'deliver_now',
                   { params: { user: work.depositor, work_version: work_version }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when an subsequent version deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }
        let(:work_version) { build(:work_version, :depositing, version: 2, work: work) }
        let(:work) { create(:work, collection: collection, druid: 'druid:foo') }

        it 'transitions to deposited' do
          expect { work_version.deposit_complete! }
            .to change(work_version, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'new_version_deposited_email', 'deliver_now',
                   { params: { user: work.depositor, work_version: work_version }, args: [] }
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
                   { params: { user: work.depositor, work_version: work_version }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end
    end

    describe 'a submit_for_review event' do
      let(:collection) { build(:collection, reviewed_by: [depositor, reviewer]) }
      let(:depositor) { build(:user) }
      let(:reviewer) { build(:user) }

      context 'when work is first_draft' do
        let(:work_version) { create(:work_version, :first_draft, work: work) }
        let(:work) { create(:work, collection: collection, depositor: depositor) }

        it 'transitions to pending_approval' do
          expect { work_version.submit_for_review! }
            .to change(work_version, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work_version: work_version }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: depositor, work_version: work_version }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when work was rejected' do
        let(:work_version) { create(:work_version, :rejected, work: work) }
        let(:work) { create(:work, collection: collection, depositor: depositor) }

        it 'transitions to pending_approval' do
          expect { work_version.submit_for_review! }
            .to change(work_version, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work_version: work_version }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: depositor, work_version: work_version }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end
    end

    describe 'a reject event' do
      let(:work_version) { create(:work_version, :pending_approval, work: work) }
      let(:work) { create(:work) }

      it 'transitions to rejected' do
        expect { work_version.reject! }
          .to change(work_version, :state)
          .to('rejected')
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                 'WorksMailer', 'reject_email', 'deliver_now',
                 { params: { user: work.depositor, work_version: work_version }, args: [] }
               ))
      end
    end
  end
end
