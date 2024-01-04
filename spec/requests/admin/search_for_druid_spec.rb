# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for a DRUID' do
  let(:user) { create(:user) }
  let(:work) { create(:work, :with_druid, collection:) }
  let(:work_version) { create(:work_version, work:) }
  let(:work_druid) { work.druid }
  let(:collection) { create(:collection, :with_collection_druid) }
  let(:collection_version) { create(:collection_version, collection:) }

  before do
    work.update(head: work_version)
    collection.update(head: collection_version)
  end

  context 'when user is an application admin' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows the druid search form' do
      get '/admin/druid_searches'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Search for DRUID'
    end

    context 'when druid for a collection is found' do
      it 'redirects to collection details page' do
        get "/admin/druid_searches?query=#{collection.druid}"
        expect(response).to redirect_to(collection_version_path(collection.head))
        follow_redirect!
        expect(response.body).to include collection_version.name
        expect(response.body).to include 'Details'
      end
    end

    context 'when druid for a work is found' do
      it 'redirects to the work page' do
        get "/admin/druid_searches?query=#{work_druid}"
        expect(response).to redirect_to(work_path(work))
        follow_redirect!
        expect(response.body).to include work_version.title
      end
    end

    context 'when druid is not found' do
      it 'shows error' do
        get '/admin/druid_searches?query=notfoundquery'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'DRUID not found'
      end
    end
  end

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden' do
      get '/admin/druid_searches'
      expect(response).to redirect_to(root_url)
    end
  end
end
