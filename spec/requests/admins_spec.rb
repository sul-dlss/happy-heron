# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin dashboard' do
  let(:user) { create(:user) }

  context 'when user is an application admin' do
    let(:collection) { create(:collection, creator: user) }
    let(:collection_version) { create(:collection_version_with_collection, collection:) }
    let(:work1) { create(:work, :with_druid, owner: user, collection:) }
    let(:work_version1) { create(:work_version, state: 'deposited', work: work1) }
    let(:work2) { create(:work, owner: user, collection:) }
    let(:work_version2) { create(:work_version, state: 'first_draft', work: work2) }

    before do
      collection.update(updated_at: '2020-12-02')
      work1.update(head: work_version1)
      work2.update(head: work_version2)
      collection.update(head: collection_version)

      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows admin dashboard' do
      get '/admin'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Admin dashboard'
      expect(response.body).to include 'collectionsTable'
      expect(response.body).to include 'Items recent activity'
      expect(response.body).to include 'Collections recent activity'
      expect(response.body).to include 'Locked items'
    end

    context 'when user is viewing recent items activity' do
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
      end
    end

    context 'when user is viewing recent collections activity' do
      before do
        create(:embargo_lifted_event, eventable: collection, created_at: 3.days.ago)
        create(:event, eventable: collection)
      end

      it 'shows recent activity' do
        get '/admin/collections_recent_activity?days=1'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'collectionsActivityFrame'
        expect(response.body).to include collection_version.name
        expect(response.body).to include 'MyString'
      end
    end

    context 'when user is viewing locked items' do
      before do
        work1.update(locked: true)
      end

      it 'shows locked items' do
        get '/admin/locked_items'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'lockedItemsFrame'
        expect(response.body).to include collection_version.name
        expect(response.body).to include work1.druid_without_namespace
        expect(response.body).to include user.sunetid
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

    it 'is forbidden to view items activity' do
      get '/admin/items_recent_activity'
      expect(response).to redirect_to(root_url)
    end

    it 'is forbidden to view collections activity' do
      get '/admin/collections_recent_activity'
      expect(response).to redirect_to(root_url)
    end
  end
end
