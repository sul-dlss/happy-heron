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
    let(:collection) { create(:collection, managed_by: [user]) }

    before do
      sign_in user
    end

    describe 'show the form for an existing object' do
      before do
        create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection: collection)
      end

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
            access: 'world',
            required_license: 'CC0-1.0',
            manager_sunets: user.sunetid,
            depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi',
            email_depositors_status_changed: true,
            contact_emails_attributes: {}
          }.tap do |param|
            collection_version.contact_emails.each_with_object(param[:contact_emails_attributes])
                              .with_index do |(author, attrs), index|
              attrs[index.to_s] = { '_destroy' => 'false', 'id' => author.id, 'email' => 'bob@foo.io' }
            end
          end
        end

        context 'when an existing collection is updated' do
          let(:collection_version) do
            create(:collection_version_with_collection, :deposited, :with_contact_emails, collection: collection)
          end

          it 'updates the collection' do
            patch "/collections/#{collection.id}", params: { collection: collection_params }
            expect(response).to redirect_to(collection)
            expect(collection.depositors.size).to eq 6
            collection.reload
            expect(collection.email_depositors_status_changed).to be true
          end
        end

        context 'when the review workflow is set to disabled' do
          let(:collection) { create(:collection, :with_reviewers, managed_by: [user]) }

          let(:collection_params) do
            {
              access: 'world',
              required_license: 'CC0-1.0',
              manager_sunets: user.sunetid,
              depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi',
              email_depositors_status_changed: true,
              review_enabled: 'false',
              reviewer_sunets: 'asdf'
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection: collection)
          end

          it 'removes the reviewers' do
            patch "/collections/#{collection.id}", params: { collection: collection_params, commit: deposit_button }
            expect(response).to redirect_to(collection)
            expect(collection.reload.reviewed_by).to be_empty
          end
        end

        context 'when the collection was previously deposited' do
          let(:collection) do
            create(:collection, :with_depositors, :email_depositors_status_changed, depositor_count: 2,
                                                                                    managed_by: [user])
          end
          let(:collection_params) do
            {
              access: 'world',
              required_license: 'CC0-1.0',
              manager_sunets: user.sunetid,
              depositor_sunets: collection.depositors.first.sunetid,
              email_depositors_status_changed: true,
              review_enabled: 'false',
              reviewer_sunets: ''
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection: collection)
            allow(CollectionObserver).to receive(:after_update_published)
          end

          it 'runs the observer method after_update_published' do
            patch "/collections/#{collection.id}",
                  params: { collection: collection_params, commit: save_draft_button }

            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection)
            expect(CollectionObserver).to have_received(:after_update_published)
          end
        end

        context 'when depositors or reviewers are removed from a collection' do
          let(:reviewer) { create(:user, email: 'v.stern@stanford.edu') }
          let(:reviewer2) { create(:user, email: 'w.a.sterner@stanford.edu') }
          let!(:removed_depositor) { collection.depositors.second } # needs to be instantiated before collection edit
          let(:collection) do
            create(:collection, :with_depositors, :email_when_participants_changed,
                   depositor_count: 2, managed_by: [user], reviewed_by: [reviewer, reviewer2])
          end
          let(:collection_params) do
            {
              access: 'world',
              required_license: 'CC0-1.0',
              manager_sunets: user.sunetid,
              depositor_sunets: collection.depositors.first.sunetid,
              email_depositors_status_changed: true,
              review_enabled: 'true',
              reviewer_sunets: 'v.stern'
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, collection: collection)
          end

          it 'logs the changes in the event description' do
            patch "/collections/#{collection.id}",
                  params: { collection: collection_params, commit: save_draft_button }
            event_description = collection.reload.events.order(created_at: :desc).take.description
            expect(event_description).to match(/Removed reviewers: w.a.sterner/)
            expect(event_description).to match(/Removed depositors: #{removed_depositor.sunetid}/)
          end

          context 'when participant change emails are off' do
            let(:no_notification_param) { collection_params.merge(email_when_participants_changed: false) }

            it 'still logs the changes in the event description' do
              patch "/collections/#{collection.id}",
                    params: { collection: collection_params, commit: save_draft_button }
              event_description = collection.reload.events.order(created_at: :desc).take.description
              expect(event_description).to match(/Removed reviewers: w.a.sterner/)
              expect(event_description).to match(/Removed depositors: #{removed_depositor.sunetid}/)
            end
          end
        end
      end

      context 'when collection fails to save' do
        let(:collection_params) do
          {
            release_option: ''
          }
        end

        before do
          create(:collection_version_with_collection, :version_draft, collection: collection)
        end

        it 'renders the page again' do
          patch "/collections/#{collection.id}",
                params: { collection: collection_params, commit: deposit_button }
          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to include 'Either a required license or a default license must be present'
        end
      end
    end
  end
end
