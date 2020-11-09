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
          expect(collection.depositors).to include(User.find_by!(email: 'maya.aguirre@stanford.edu'))
          expect(collection.managers).to eq user.email
        end

        context 'when overriding manager list and review workflow defaults' do
          let(:review_workflow_params) do
            {
              managers: 'maya.aguirre,jcairns',
              review_enabled: 'true',
              reviewer_sunets: 'maya.aguirre, jcairns,faridz'
            }
          end

          before { collection_params[:collection].merge!(review_workflow_params) }

          it 'sets the managers and reviewers fields' do
            post '/collections', params: collection_params
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            collection = Collection.last
            expect(collection.managers).to eq 'maya.aguirre,jcairns'
            expect(collection.reviewers).to eq 'maya.aguirre, jcairns,faridz'
          end
        end

        context 'when review workflow is disabled' do
          let(:review_workflow_params) do
            {
              review_enabled: 'false',
              reviewer_sunets: 'maya.aguirre ,jcairns , faridz'
            }
          end

          before { collection_params[:collection].merge!(review_workflow_params) }

          it 'nils out the reviewers field' do
            post '/collections', params: collection_params
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            collection = Collection.last
            expect(collection.reviewers).to eq nil
          end
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

    describe 'allowing content changes' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

      context 'when false' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        end

        it 'redirects and displays alert' do
          get '/collections/new'
          expect(response).to redirect_to(:root)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include alert_text
        end
      end

      context 'when true' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
        end

        it 'does NOT display alert' do
          get '/collections/new'
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include alert_text
        end
      end
    end
  end

  context 'with an authenticated collection manager' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managers: [user.sunetid]) }

    before do
      sign_in user
    end

    describe 'edit' do
      it 'allows GETs to /collections/{id}/edit' do
        get "/collections/#{collection.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'update' do
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

        context 'when collection has reviewers specified' do
          let(:collection) { create(:collection, managers: [user.sunetid], reviewers: 'asdf') }
          let(:review_workflow_params) do
            {
              review_enabled: 'false',
              reviewer_sunets: 'asdf'
            }
          end

          before { collection_params[:collection].merge!(review_workflow_params) }

          it 'removes the reviewers when the review workflow is set to disabled' do
            patch "/collections/#{collection.id}", params: collection_params
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            expect(collection.reload.reviewers).to eq nil
          end
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
end
