# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin dashboard' do
  let(:user) { create(:user) }

  context 'when user is an application admin' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows the admin dashboard' do
      get '/admin'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Admin dashboard'
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
