# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search for a user' do
  let(:user) { create(:user) }

  context 'when user is an application admin' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows the search form' do
      get '/admin/users'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Search for user'
    end

    context 'when users are found' do
      let!(:collection_version) { create(:collection_version_with_collection, reviewed_by: [target]) }
      let(:target) { create(:user) }

      it 'shows results' do
        get "/admin/users?query=#{target.sunetid}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include collection_version.name
      end
    end

    context 'when no users are found' do
      it 'shows error' do
        get '/admin/users?query=notfoundquery'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'SUNet ID not found. Please try searching for another ' \
                                         'SUNet ID or try again if you think this is an error.'
      end
    end
  end

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden' do
      get '/admin/users'
      expect(response).to redirect_to(root_url)
    end
  end
end
