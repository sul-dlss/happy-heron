# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating a first draft (non-deposited) collection' do
  let(:deposit_button) { 'Deposit' }
  let(:save_draft_button) { 'Save as draft' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with an authenticated collection manager' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managed_by: [user]) }

    before do
      sign_in user
    end

    describe 'redirects and renders the full collection form with settings and details' do
      before do
        create(:collection_version_with_collection, :first_draft, :with_contact_emails, collection: collection)
      end

      it 'redirects GETs to /collections/{id}/edit to /first_draft_collections/{id}/edit' do
        get "/collections/#{collection.id}/edit"
        expect(response).to redirect_to(edit_first_draft_collection_url(collection.id))
        expect(response).to have_http_status(:redirect)
      end

      it 'redirects GETs to /collection_versions/{collection_version.id}/edit to /first_draft_collections/{id}/edit' do
        get "/collection_versions/#{collection.head.id}/edit"
        expect(response).to redirect_to(edit_first_draft_collection_url(collection.id))
        expect(response).to have_http_status(:redirect)
      end

      it 'renders the full collection form with all fields and both buttons' do
        get "/first_draft_collections/#{collection.id}/edit"
        expect(response.body).to include 'Collection name' # a field in the details
        expect(response.body).to include 'Require license for all deposits' # a field in the settings
        expect(response.body).to include deposit_button
        expect(response.body).to include save_draft_button
      end
    end

    describe 'submit the form' do
      context 'when a first draft collection is saved' do
        let(:collection_version) do
          create(:collection_version_with_collection, :first_draft, :with_contact_emails, collection: collection)
        end

        let(:collection_params) do
          {
            name: 'This is a new collection name',
            description: 'This is a new collection description',
            access: 'world',
            required_license: 'CC0-1.0',
            manager_sunets: user.sunetid,
            depositor_sunets: 'maya.aguirre, jcairns, cchavez, premad, giancarlo, zhengyi',
            email_depositors_status_changed: true,
            contact_emails_attributes: {}
          }.tap do |param|
            collection_version.contact_emails.each_with_object(param[:contact_emails_attributes])
                              .with_index do |(author, attrs), index|
              attrs[index.to_s] = { '_destroy' => 'false', 'id' => author.id, 'email' => 'bob@foo.io' }
            end
          end
        end

        it 'updates the collection settings and details when saving a draft' do
          expect(collection_version.name).not_to eq collection_params[:name]
          expect(collection.depositors.size).not_to eq 6
          patch "/first_draft_collections/#{collection.id}",
                params: { collection: collection_params, commit: save_draft_button }
          expect(response).to redirect_to(collection)
          collection.reload
          collection_version.reload
          expect(collection_version.name).to eq collection_params[:name] # new value showing a detail was updated
          expect(collection.depositors.size).to eq 6 # new value showing a setting was updated
          expect(collection.email_depositors_status_changed).to be true
          expect(collection_version.state).to eq 'first_draft'
        end

        it 'updates the collection settings and details when submitting for deposit' do
          expect(collection_version.name).not_to eq collection_params[:name]
          expect(collection.depositors.size).not_to eq 6
          patch "/first_draft_collections/#{collection.id}",
                params: { collection: collection_params, commit: deposit_button }
          expect(response).to redirect_to(dashboard_path)
          collection.reload
          collection_version.reload
          expect(collection_version.name).to eq collection_params[:name] # new value showing a detail was updated
          expect(collection.depositors.size).to eq 6 # new value showing a setting was updated
          expect(collection.email_depositors_status_changed).to be true
          expect(collection_version.state).to eq 'depositing'
        end

        it 're-renders the collection settings page when submitting for deposit but not valid' do
          patch "/first_draft_collections/#{collection.id}",
                params: { collection: collection_params.merge(required_license: '', name: ''), commit: deposit_button }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include 'is-invalid'
          expect(collection_version.state).to eq 'first_draft'
        end
      end
    end
  end
end
