# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { build(:collection, :with_works) }

  it 'has many works' do
    expect(collection.works).to all(be_a(Work))
  end

  it 'has a valid contact email' do
    collection.contact_email = 'notavalidemail'
    expect { collection.save! }.to raise_error(ActiveRecord::RecordInvalid, /Contact email is invalid/)
  end

  describe '#purl' do
    context 'with a druid' do
      it 'constructs purl' do
        collection.update(druid: 'druid:hb093rg5848')
        expect(collection.purl).to eq('https://purl.stanford.edu/hb093rg5848')
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(collection.purl).to eq(nil)
      end
    end
  end

  describe 'state machine flow' do
    it 'starts in first draft' do
      expect(collection.state).to eq('first_draft')
    end

    describe 'a begin_deposit event' do
      before do
        allow(DepositCollectionJob).to receive(:perform_later)
      end

      it 'transitions from first_draft to depositing' do
        expect { collection.begin_deposit! }
          .to change(collection, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
        expect(DepositCollectionJob).to have_received(:perform_later).with(collection)
      end
    end

    describe 'an update_metadata event' do
      let(:collection) { create(:collection, :deposited) }
      let(:change_set) { CollectionChangeSet.from(collection).to(collection) }

      before do
        collection.event_context = { user: collection.creator, change_set: change_set }
      end

      it 'transitions to version draft' do
        expect { collection.update_metadata! }
          .to change(collection, :state)
          .from('deposited').to('version_draft')
          .and change(Event, :count).by(1)
      end
    end

    describe 'a deposit_complete event' do
      let(:collection) { create(:collection, :depositing, druid: 'druid:foo') }

      it 'transitions to deposited' do
        expect { collection.deposit_complete! }
          .to change(collection, :state)
          .to('deposited')
          .and change(Event, :count).by(1)
      end
    end
  end
end
