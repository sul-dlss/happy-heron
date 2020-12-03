# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work detail' do
  let(:work) { create(:work) }
  let(:work_with_no_title) { create(:work, title: '') }
  let(:collection) { create(:collection) }

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /works/:work_id to login URL' do
      get "/works/#{work.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    it 'displays the work' do
      get "/works/#{work.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include work.title
    end

    it 'displays a default title for a work when it is blank' do
      get "/works/#{work_with_no_title.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'No title'
    end
  end
end
