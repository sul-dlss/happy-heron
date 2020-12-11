# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating an existing collection' do
  let(:deposit_button) { 'Deposit' }
  let(:save_draft_button) { 'Save as draft' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with an authenticated collection manager' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managers: [user]) }

    before do
      sign_in user
    end

    describe 'show the form for an existing object' do
      it 'allows GETs to /collections/{id}/edit' do
        get "/collections/#{collection.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'submit the form' do
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
          patch "/collections/#{collection.id}", params: { collection: collection_params, commit: deposit_button }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(dashboard_path)
          expect(collection.depositors.size).to eq 6
          collection.reload
          expect(collection.email_depositors_status_changed).to be true
        end

        it 'updates the collection via draft save' do
          patch "/collections/#{collection.id}", params: { collection: collection_params, commit: save_draft_button }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(collection_path(collection))
          expect(collection.depositors.size).to eq 6
        end

        context 'when the review workflow is set to disabled' do
          let(:collection) { create(:collection, :with_reviewers, managers: [user]) }

          let(:collection_params) do
            {
              name: 'My Test Collection',
              description: 'This is a very good collection.',
              contact_email: user.email,
              access: 'world',
              manager_sunets: user.sunetid,
              depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi',
              email_depositors_status_changed: true,
              review_enabled: 'false',
              reviewer_sunets: 'asdf'
            }
          end

          it 'removes the reviewers' do
            patch "/collections/#{collection.id}", params: { collection: collection_params, commit: deposit_button }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            expect(collection.reload.reviewers).to be_empty
          end
        end

        context 'when depositors are removed from a collection' do
          let(:collection) { create(:collection, :deposited, :with_depositors, depositor_count: 2, managers: [user]) }
          let(:collection_params) do
            {
              name: 'My Test Collection',
              description: 'This is a very good collection.',
              contact_email: user.email,
              access: 'world',
              manager_sunets: user.sunetid,
              depositor_sunets: collection.depositors.first.sunetid,
              email_depositors_status_changed: true,
              review_enabled: 'false',
              reviewer_sunets: ''
            }
          end

          it 'sends emails to those removed' do
            expect do
              patch "/collections/#{collection.id}",
                    params: { collection: collection_params, commit: save_draft_button }
            end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
              'CollectionsMailer', 'deposit_access_removed_email', 'deliver_now',
              { params: { user: collection.depositors.last, collection: collection }, args: [] }
            )
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection)
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
                params: { collection: collection_params, format: :json, commit: deposit_button }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json['name']).to eq ["can't be blank"]
          expect(json['reviewerSunets']).to eq ['must be provided when review is enabled']
        end
      end
    end
  end
end
