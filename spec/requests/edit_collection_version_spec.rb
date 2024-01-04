# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating an existing collection version' do
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

    describe 'show the form for an existing object in first draft' do
      let(:collection_version) do
        create(:collection_version_with_collection, :version_draft, :with_contact_emails, :with_version_description,
               collection:)
      end

      it 'allows GETs to /collection_versions/{id}/edit and shows saved version description' do
        get "/collection_versions/#{collection_version.id}/edit"
        expect(response.body).to include('really important changes')
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'show the form for an existing already deposited object' do
      let(:collection_version) do
        create(:collection_version_with_collection, :with_contact_emails, :with_version_description,
               collection:)
      end

      it 'allows GETs to /collection_versions/{id}/edit and shows blank version description' do
        get "/collection_versions/#{collection_version.id}/edit"
        expect(response.body).not_to include('really important changes')
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'submit the form' do
      context 'when collection saves' do
        let(:collection_params) do
          {
            name: 'My Test Collection',
            description: 'This is a very good collection.',
            contact_emails_attributes: {}
          }.tap do |param|
            collection_version.contact_emails.each_with_object(param[:contact_emails_attributes])
                              .with_index do |(author, attrs), index|
              attrs[index.to_s] = { '_destroy' => 'false', 'id' => author.id, 'email' => 'bob@foo.io' }
            end
          end
        end

        context 'when deposit button is pressed for a previously deposited version' do
          let(:collection_version) do
            create(:collection_version_with_collection, :deposited, :with_contact_emails, collection:)
          end

          it 'updates the collection via deposit button' do
            patch "/collection_versions/#{collection_version.id}",
                  params: { collection_version: collection_params, commit: deposit_button }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            newly_created_version = collection.reload.head
            expect(newly_created_version.name).to eq 'My Test Collection'
          end
        end

        context 'when save draft button is pressed' do
          let(:collection_version) do
            create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection:)
          end

          it 'updates the collection' do
            patch "/collection_versions/#{collection_version.id}",
                  params: { collection_version: collection_params, commit: save_draft_button }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection_version_path(collection_version))
            collection_version.reload
            expect(collection_version.name).to eq 'My Test Collection'
          end
        end
      end

      context 'when collection fails to save' do
        let(:collection_params) do
          {
            contact_emails_attributes: { '0' => { 'email' => 'notvalid', 'id' => '' } }
          }
        end

        let(:collection_version) do
          create(:collection_version_with_collection, :version_draft, collection:)
        end

        it 'renders the page again' do
          patch "/collection_versions/#{collection_version.id}",
                params: { collection_version: collection_params, commit: deposit_button }
          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to match(/input class="[\w\- ]*is-invalid[\w\- ]*"/)
        end
      end
    end
  end
end
