# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the collection detail page' do
  let(:collection) { create(:collection, :with_managers, :with_depositors) }
  let(:collection2) { create(:collection, :with_reviewers) }

  context 'with an admin user' do
    let(:user) { create(:user) }
    let(:depositors) { collection.depositors.pluck(:email).join(', ') }
    let(:managers) { collection.managers.pluck(:email).join(', ') }
    let(:reviewers) { collection2.reviewers.pluck(:email).join(', ') }

    before do
      sign_in user, groups: [Settings.authorization_workgroup_names.administrators]
    end

    it 'displays the collection detail page with reviews disabled' do
      get "/collections/#{collection.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include collection.name
      expect(response.body).to include depositors
      expect(response.body).to include managers
      expect(response.body).to include 'Off'
    end

    it 'displays the collection detail page with reviews enabled' do
      get "/collections/#{collection2.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'On'
      expect(response.body).to include reviewers
    end
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id to login URL' do
      get "/collections/#{collection.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
