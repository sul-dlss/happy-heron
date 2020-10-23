# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard requests' do
  let(:user) { create(:user) }

  before { sign_out }

  context 'when user has no workgroup' do
    before { sign_in user }

    it 'returns an unauthorized http status code' do
      get '/dashboard'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when user is not an application user' do
    before { sign_in user, groups: ['workgroup:foo'] }

    it 'returns an unauthorized http status code' do
      get '/dashboard'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when user is a collection creator' do
    before { sign_in user, groups: ['dlss:hydrus-app-collection-creators'] }

    it 'shows links to create in a collection' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Your collections'
      expect(response.body).to include '+ Create a new collection'
    end
  end

  context 'when user is an application admin' do
    before { sign_in user, groups: ['dlss:hydrus-app-adminstrators'] }

    it 'shows the dashboard' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
    end

    it 'does not show a link to create collections' do
      get '/dashboard'
      expect(response.body).not_to include '+ Create a new collection'
    end
  end
end
