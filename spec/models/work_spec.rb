# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  subject(:work) { build(:work, :with_authors, :with_related_links, :with_related_works, :with_attached_file) }

  it 'belongs to a collection' do
    expect(work.collection).to be_a(Collection)
  end

  it 'has many contributors' do
    expect(work.contributors).to all(be_a(Contributor))
  end

  it 'has many related links' do
    expect(work.related_links).to all(be_a(RelatedLink))
  end

  it 'has many related works' do
    expect(work.related_works).to all(be_a(RelatedWork))
  end

  it 'has attached files' do
    expect(work.attached_files).to be_present
  end

  describe 'contact_email' do
    describe 'validation' do
      subject(:work) { build(:work, contact_email: email) }

      context 'with invalid email' do
        let(:email) { 'notavalidemail' }

        it { is_expected.not_to be_valid }
      end

      context 'with a blank email' do
        let(:email) { '' }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'created_edtf' do
    describe 'validation' do
      subject(:work) { build(:work, created_edtf: date_string) }

      context 'with non-EDTF value' do
        let(:date_string) { 'foo bar' }

        it 'raises a type error' do
          expect { work }.to raise_error TypeError
        end
      end

      context 'with EDTF value' do
        let(:date_string) { EDTF.parse('2019-04-04') }

        it { is_expected.to be_valid }
      end
    end

    describe 'serialization' do
      subject(:work) { build(:work, created_edtf: date) }

      context 'with a single point' do
        let(:date) { EDTF.parse('2020-11') }

        it 'records an EDTF string' do
          expect(work.created_edtf.to_edtf).to eq '2020-11'
        end
      end

      context 'with an interval' do
        let(:date) { EDTF.parse('2020-11/2021') }

        it 'records an EDTF string' do
          expect(work.created_edtf.to_s).to eq '2020-11/2021'
        end
      end
    end
  end

  describe 'published_edtf' do
    describe 'serialization' do
      subject(:work) { build(:work, published_edtf: date) }

      context 'with a single point' do
        let(:date) { EDTF.parse('2020-11') }

        it 'records an EDTF string' do
          expect(work.published_edtf.to_edtf).to eq '2020-11'
        end
      end

      context 'with an interval' do
        let(:date) { EDTF.parse('2020-11/2021') }

        it 'records an EDTF string' do
          expect(work.published_edtf.to_s).to eq '2020-11/2021'
        end
      end
    end
  end

  describe 'license validation' do
    context 'with an empty license' do
      let(:work) { build(:work, license: nil) }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with a bogus license' do
      let(:work) { build(:work, license: 'Steal all my stuff') }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with a valid license' do
      let(:work) { build(:work, license: License.license_list.first) }

      it 'validates' do
        expect(work).to be_valid
      end
    end
  end

  describe 'type and subtype validation' do
    context 'with an empty work type' do
      let(:work) { build(:work, work_type: nil) }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with a missing work type' do
      let(:work) { build(:work, work_type: 'a pile of something') }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with an invalid subtype/work_type combo' do
      let(:work) { build(:work, work_type: 'data', subtype: ['Animation']) }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with a work_type that requires a user-supplied subtype and is empty' do
      let(:work) { build(:work, work_type: 'other', subtype: []) }

      it 'does not validate' do
        expect(work).not_to be_valid
      end
    end

    context 'with a work_type that requires a user-supplied subtype and is present' do
      let(:work) { build(:work, work_type: 'other', subtype: ['Pill bottle']) }

      it 'does not validate' do
        expect(work).to be_valid
      end
    end

    context 'with a valid subtype/work_type combo ' do
      let(:work) { build(:work, work_type: 'data', subtype: ['Software/code']) }

      it 'validates' do
        expect(work).to be_valid
      end
    end
  end

  describe 'access field' do
    it 'defaults to world' do
      expect(work.access).to eq('world')
    end

    context 'with value present in enum' do
      let(:access) { 'stanford' }

      it 'is valid' do
        work.update(access: access)
        expect(work).to be_valid
      end
    end

    context 'with value absent from enum' do
      let(:access) { 'rutgers' }

      it 'raises ArgumentError' do
        expect { work.update(access: access) }.to raise_error(ArgumentError, /'#{access}' is not a valid access/)
      end
    end
  end

  describe 'state machine flow' do
    it 'starts in first draft' do
      expect(work.state).to eq('first_draft')
    end

    describe 'a begin_deposit event' do
      before do
        allow(DepositJob).to receive(:perform_later)
      end

      it 'transitions from first_draft to depositing' do
        expect { work.begin_deposit! }
          .to change(work, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
        expect(DepositJob).to have_received(:perform_later).with(work)
      end

      context 'with pending_approval on a work' do
        let(:work) { create(:work, :pending_approval) }

        it 'transitions to depositing' do
          expect { work.begin_deposit! }
            .to change(work, :state)
            .to('depositing')
            .and change(Event, :count).by(1)
          expect(DepositJob).to have_received(:perform_later).with(work)
        end
      end
    end

    describe 'an update_metadata event' do
      let(:collection) { create(:collection, :with_managers) }
      let(:work) { create(:work, state: state, collection: collection, depositor: collection.managers.first) }

      context 'when the state was deposited' do
        let(:state) { 'deposited' }

        it 'transitions to version draft' do
          expect { work.update_metadata! }
            .to change(work, :state)
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
          expect { work.update_metadata! }
            .to change(work, :state)
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
    end

    describe 'a deposit_complete event' do
      let(:work) { build(:work, :depositing, druid: 'druid:foo', collection: collection) }

      context 'when an initial deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }

        it 'transitions to deposited' do
          expect { work.deposit_complete! }
            .to change(work, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'deposited_email', 'deliver_now',
                   { params: { user: work.depositor, work: work }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when an subsequent version deposit into a non-reviewed collection' do
        let(:collection) { create(:collection) }
        let(:work) { build(:work, :depositing, version: 2, druid: 'druid:foo', collection: collection) }

        it 'transitions to deposited' do
          expect { work.deposit_complete! }
            .to change(work, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'new_version_deposited_email', 'deliver_now',
                   { params: { user: work.depositor, work: work }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when in a reviewed collection' do
        let(:collection) { create(:collection, :with_reviewers) }

        it 'transitions to deposited' do
          expect { work.deposit_complete! }
            .to change(work, :state)
            .to('deposited')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'approved_email', 'deliver_now',
                   { params: { user: work.depositor, work: work }, args: [] }
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
        let(:work) { create(:work, :first_draft, collection: collection, depositor: depositor) }

        it 'transitions to pending_approval' do
          expect { work.submit_for_review! }
            .to change(work, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work: work }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: depositor, work: work }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end

      context 'when work was rejected' do
        let(:work) { create(:work, :rejected, collection: collection, depositor: depositor) }

        it 'transitions to pending_approval' do
          expect { work.submit_for_review! }
            .to change(work, :state)
            .to('pending_approval')
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'ReviewersMailer', 'submitted_email', 'deliver_now',
                   { params: { user: reviewer, work: work }, args: [] }
                 ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                   'WorksMailer', 'submitted_email', 'deliver_now',
                   { params: { user: depositor, work: work }, args: [] }
                 ))
            .and change(Event, :count).by(1)
        end
      end
    end

    describe 'a reject event' do
      let(:work) { create(:work, :pending_approval) }

      it 'transitions to rejected' do
        expect { work.reject! }
          .to change(work, :state)
          .to('rejected')
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                 'WorksMailer', 'reject_email', 'deliver_now',
                 { params: { user: work.depositor, work: work }, args: [] }
               ))
      end
    end
  end

  describe '#purl' do
    context 'with a druid' do
      it 'constructs purl' do
        work.update(druid: 'druid:hb093rg5848')
        expect(work.purl).to eq('https://purl.stanford.edu/hb093rg5848')
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(work.purl).to eq(nil)
      end
    end
  end
end
