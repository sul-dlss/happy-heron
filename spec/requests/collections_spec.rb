# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collections requests' do
  let(:collection) { create(:collection) }

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id/works/new to login URL' do
      get "/collections/#{collection.id}/works/new"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects from /collections/new to login URL' do
      get '/collections/new'
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'allows GETs to /collections/:collection_id/works/new' do
      get "/collections/#{collection.id}/works/new"
      expect(response).to have_http_status(:ok)
    end

    it 'allows GETs to /collections/new' do
      get '/collections/new'
      expect(response).to have_http_status(:ok)
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
end
