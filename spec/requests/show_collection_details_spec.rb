# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the collection details page' do
  context 'with an admin user' do
    let(:user) { create(:user) }

    before do
      sign_in user, groups: [Settings.authorization_workgroup_names.administrators]
    end

    context 'with reviews disabled' do
      let(:collection_version) { create(:collection_version_with_collection) }

      it 'displays the collection detail page' do
        get "/collection_versions/#{collection_version.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include collection_version.name
      end
    end
  end

  context 'with unauthenticated user' do
    let(:collection_version) { create(:collection_version_with_collection) }

    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id to login URL' do
      get "/collection_versions/#{collection_version.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
