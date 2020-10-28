# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collections requests' do
  let(:collection) { create(:collection) }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/new to login URL' do
      get '/collections/new'
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an authenticated user who is not in any application workgroups' do
    let(:user) { create(:user) }
    let(:alert_text) { 'You are not authorized to perform the requested action' }

    before do
      sign_in user, groups: ['sdr:baz']
    end

    it 'does not authorize GETs to /collections/new' do
      get '/collections/new'
      expect(response).to redirect_to(:root)
      follow_redirect!
      expect(response).to be_successful
      expect(response.body).to include alert_text
    end

    it 'does not allow the user to save a collection' do
      post '/collections', params: { collection: { should_not: 'even read these params' } }
      expect(response).to redirect_to(:root)
      follow_redirect!
      expect(response).to be_successful
      expect(response.body).to include alert_text
    end
  end

  context 'with an authenticated collection creator' do
    let(:user) { create(:user) }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    it 'allows GETs to /collections/new' do
      get '/collections/new'
      expect(response).to have_http_status(:ok)
    end

    describe 'edit' do
      let(:collection) { create(:collection) }

      it 'allows GETs to /collections/{id}/edit' do
        get "/collections/#{collection.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'create' do
      context 'when collection saves' do
        let(:collection_params) do
          {
            collection: {
              name: 'My Test Collection',
              description: 'This is a very good collection.',
              contact_email: user.email,
              access: 'world',
              managers: user.email,
              depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi'
            }
          }
        end

        it 'creates a new collection' do
          post '/collections', params: collection_params
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(dashboard_path)
          collection = Collection.last
          expect(collection.depositors.size).to eq 6
          expect(collection.depositors).to all(be_kind_of(User))
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
          expect(response.body).to include 'Create a collection'
        end
      end
    end

    describe 'update' do
      let(:collection) { create(:collection) }

      context 'when collection saves' do
        let(:collection_params) do
          {
            collection: {
              name: 'My Test Collection',
              description: 'This is a very good collection.',
              contact_email: user.email,
              access: 'world',
              managers: user.email,
              depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi'
            }
          }
        end

        it 'creates a new collection' do
          patch "/collections/#{collection.id}", params: collection_params
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(dashboard_path)
          expect(collection.depositors.size).to eq 6
        end
      end

      context 'when collection fails to save' do
        let(:collection_params) do
          {
            collection: {
              name: '',
              depositor_sunets: ''
            }
          }
        end

        it 'renders the page again' do
          patch "/collections/#{collection.id}", params: collection_params
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('All fields are required, unless otherwise noted.')
        end
      end
    end
  end

  context 'when Settings.allow_sdr_content_changes is' do
    let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

    describe 'false' do
      before do
        allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
      end

      it 'redirects and displays alert' do
        get '/collections/new'
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end
    end

    describe 'true' do
      it 'does NOT display alert' do
        get '/collections/new'
        expect(response).to be_successful
        expect(response.body).not_to include alert_text
      end
    end
  end
end
