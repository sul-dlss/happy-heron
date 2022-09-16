# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  describe 'GET /show' do
    let(:user) { create(:user) }
    let(:rendered) do
      Capybara::Node::Simple.new(response.body)
    end

    before do
      sign_in user
      create(:collection_version_with_collection, name: 'Barbara McClintock', managed_by: [user])
      create(:collection_version_with_collection, name: 'David Card', reviewed_by: [user])
    end

    it 'shows the collections that we have access to' do
      get profile_path
      expect(response).to have_http_status(:ok)
      expect(rendered).to have_text 'Barbara McClintock'
      expect(rendered).to have_text 'David Card'
    end
  end
end
