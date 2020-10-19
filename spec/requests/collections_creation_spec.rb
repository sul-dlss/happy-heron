# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collection creation' do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when collection saves' do
    let(:collection_params) do
      {
        collection: {
          name: 'My Test Collection',
          description: 'This is a very good collection.',
          contact_email: user.email,
          visibility: 'world',
          managers: user.email
        }
      }
    end

    it 'creates a new collection' do
      post '/collections', params: collection_params
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(dashboard_path)
    end
  end

  context 'when collection fails to save' do
    let(:collection_params) do
      {
        collection: {
          visibility: 'world'
        }
      }
    end

    it 'renders the page again' do
      post '/collections', params: collection_params
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Deposit your work')
    end
  end
end
