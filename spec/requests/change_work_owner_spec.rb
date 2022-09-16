# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Change owner of a work' do
  let(:user) { create(:user) }
  let(:orig_owner) { create(:user) }
  let(:new_owner) { create(:user) }
  let(:manager) { create(:user) }
  let(:reviewer) { create(:user) }

  let(:work_version) { create(:work_version, work:) }
  let(:collection_version) do
    create(:collection_version_with_collection, managed_by: [manager], reviewed_by: [reviewer])
  end
  let(:work) { create(:work, owner: orig_owner, collection: collection_version.collection) }

  before do
    work.update(head: work_version)
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  context 'when new owner is different than original owner' do
    it 'allows owner to be changed' do
      expect { put owners_path(work), params: { sunetid: new_owner.sunetid } }
        .to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(4).times

      follow_redirect!
      # Flash message
      expect(response.body).to include 'Owner updated'
      expect(work.collection.reload.depositors).to include new_owner
    end
  end

  context 'when new owner is already a depositor' do
    let(:collection) { collection_version.collection }

    before do
      collection.depositors << new_owner
      collection.save!
    end

    it 'allows owner to be changed' do
      expect(collection.depositors).to include new_owner
      put owners_path(work), params: { sunetid: new_owner.sunetid }

      follow_redirect!
      # Flash message
      expect(response.body).to include 'Owner updated'
      expect(collection.reload.depositors).to include new_owner
    end
  end

  context 'when new owner is same as original owner' do
    it 'prevents owner from being changed' do
      expect { put owners_path(work), params: { sunetid: orig_owner.sunetid } }
        .not_to have_enqueued_job(ActionMailer::MailDeliveryJob)

      follow_redirect!
      # Flash message
      expect(response.body).to include 'Cannot change owner to the same user'
      expect(work.collection.reload.depositors).not_to include new_owner
    end
  end
end
