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

    it 'shows a link to create collections and admin' do
      get '/admin'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Admin dashboard'
      expect(response.body).to include 'collectionsTable'
    end
  end

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden' do
      get '/admin'
      expect(response).to redirect_to(root_url)
    end
  end
end
