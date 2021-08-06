# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the collection settings page' do
  context 'with an admin user' do
    let(:user) { create(:user) }
    let(:depositors) { collection.depositors.map(&:sunetid).join(', ') }
    let(:managers) { collection.managed_by.map(&:sunetid).join(', ') }

    before do
      create(:collection_version_with_collection, collection: collection)
      sign_in user, groups: [Settings.authorization_workgroup_names.administrators]
    end

    context 'with reviews disabled' do
      let(:collection) { create(:collection, :with_managers, :with_depositors, :with_events) }

      it 'displays the collection detail page' do
        get "/collections/#{collection.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include collection.head.name
        expect(response.body).to include depositors
        expect(response.body).to include managers
        expect(response.body).to include 'Off'
        expect(response.body).to include 'History'
        expect(response.body).to include(/Updated by user/).exactly(3).times # verifies event history is rendered
      end
    end

    context 'with reviews enabled' do
      let(:collection) { create(:collection, :with_reviewers) }
      let(:reviewers) { collection.reviewed_by.map(&:sunetid).join(', ') }

      it 'displays the collection detail page' do
        get "/collections/#{collection.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'On'
        expect(response.body).to include reviewers
      end
    end
  end

  context 'with unauthenticated user' do
    let(:collection) { create(:collection) }

    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id to login URL' do
      get "/collections/#{collection.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
