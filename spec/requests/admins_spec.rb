# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin dashboard' do
  let(:user) { create(:user) }

  context 'when user is an application admin' do
    let(:work_collection) { create(:collection, creator: user) }
    let(:work1) { create(:work, owner: user, collection: work_collection) }
    let(:work_version1) { create(:work_version, state: 'deposited', work: work1) }
    let(:work2) { create(:work, owner: user, collection: work_collection) }
    let(:work_version2) { create(:work_version, state: 'first_draft', work: work2) }

    before do
      create(:collection_version_with_collection, collection: work_collection)
      work_collection.update(updated_at: '2020-12-02')
      work1.update(head: work_version1)
      work2.update(head: work_version2)

      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows admin dashboard' do
      get '/admin'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Admin dashboard'
      expect(response.body).to include 'collectionsTable'
      expect(response.body).to include 'Items recent activity'
    end

    context 'when user is viewing recent activity' do
      before do
        create(:embargo_lifted_event, eventable: work1, created_at: 3.days.ago)
        create(:event, eventable: work2)
      end

      it 'shows recent activity' do
        get '/admin/items_recent_activity?days=1'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'itemsActivityFrame'
        expect(response.body).to include work_version2.title
        expect(response.body).to include 'MyString'
        expect(response.body).to include 'Updated by user'
        expect(response.body).not_to include 'Embargo lifted'
      end
    end
  end

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden to view admin dashboard' do
      get '/admin'
      expect(response).to redirect_to(root_url)
    end

    it 'is forbidden to view items_activity' do
      get '/admin/items_recent_activity'
      expect(response).to redirect_to(root_url)
    end
  end
end
