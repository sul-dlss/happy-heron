# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionVersion do
  subject(:collection_version) { build(:collection_version) }

  describe 'state machine flow' do
    let(:collection) { collection_version.collection }

    before do
      collection.update(head: collection_version)
    end

    describe 'a begin_deposit event' do
      let(:collection_version) { create(:collection_version, :first_draft) }

      before do
        allow(DepositCollectionJob).to receive(:perform_later)
      end

      it 'transitions from first_draft to depositing' do
        expect { collection_version.begin_deposit! }
          .to change(collection_version, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
        expect(DepositCollectionJob).to have_received(:perform_later).with(collection_version)
      end
    end

    describe 'an update_metadata event' do
      let(:collection_version) { create(:collection_version, :new) }
      let(:change_set) { CollectionChangeSet::PointInTime.new(collection).diff(collection) }

      before do
        collection.event_context = { user: collection.creator, change_set: change_set }
      end

      it 'transitions to version draft' do
        expect { collection_version.update_metadata! }
          .to change(collection_version, :state)
          .from('new').to('first_draft')
          .and change(Event, :count).by(1)
      end
    end

    describe 'a deposit_complete event' do
      let(:collection_version) { create(:collection_version, :depositing) }

      it 'transitions to deposited' do
        expect { collection_version.deposit_complete! }
          .to change(collection_version, :state)
          .to('deposited')
          .and change(Event, :count).by(1)
      end
    end
  end
end
