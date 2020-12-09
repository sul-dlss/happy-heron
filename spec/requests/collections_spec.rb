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
    let(:collection) { create(:collection, managers: [user]) }

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
            name: 'My Test Collection',
            description: 'This is a very good collection.',
            contact_email: user.email,
            access: 'world',
            manager_sunets: user.sunetid,
            depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi',
            email_depositors_status_changed: true
          }
        end

        it 'updates the collection via deposit button' do
          patch "/collections/#{collection.id}", params: { collection: collection_params, commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(dashboard_path)
          expect(collection.depositors.size).to eq 6
          collection.reload
          expect(collection.email_depositors_status_changed).to be true
        end

        it 'updates the collection via draft save' do
          patch "/collections/#{collection.id}", params: { collection: collection_params, commit: 'Save as draft' }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(collection_path(collection))
          expect(collection.depositors.size).to eq 6
        end

        context 'when collection has reviewers specified' do
          let(:collection) { create(:collection, :with_reviewers, managers: [user]) }
          let(:review_workflow_params) do
            {
              review_enabled: 'false',
              reviewer_sunets: 'asdf'
            }
          end

          before { collection_params.merge!(review_workflow_params) }

          it 'removes the reviewers when the review workflow is set to disabled' do
            patch "/collections/#{collection.id}", params: { collection: collection_params, commit: 'Deposit' }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            expect(collection.reload.reviewers).to be_empty
          end
        end
      end

      context 'when collection fails to save' do
        let(:collection_params) do
          {
            name: '',
            review_enabled: 'true',
            reviewer_sunets: ''
          }
        end

        it 'renders the page again' do
          patch "/collections/#{collection.id}",
                params: { collection: collection_params, format: :json, commit: 'Deposit' }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json['name']).to eq ["can't be blank"]
          expect(json['reviewerSunets']).to eq ['must be provided when review is enabled']
        end
      end
    end
  end
end
