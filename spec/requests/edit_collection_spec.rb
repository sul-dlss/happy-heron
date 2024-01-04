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
        create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection:)
      end

      it 'allows GETs to /collections/{id}/edit' do
        get "/collections/#{collection.id}/edit"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include '<title>SDR | MyString</title>'
      end
    end

    describe 'submit the form' do
      context 'when collection saves' do
        let(:collection_params) do
          {
            access: 'world',
            required_license: 'CC0-1.0',
            custom_rights_statement_option: 'entered_by_depositor',
            provided_custom_rights_statement: '',
            custom_rights_statement_custom_instructions: '',
            doi_option: 'depositor-selects',
            depositors_attributes: {
              '9999' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
              '9998' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
              '9997' => { 'sunetid' => 'cchavez', '_destroy' => 'false' },
              '9996' => { 'sunetid' => 'premad', '_destroy' => 'false' },
              '9995' => { 'sunetid' => 'giancarlo', '_destroy' => 'false' },
              '9994' => { 'sunetid' => 'zhengyi', '_destroy' => 'false' }
            },
            email_depositors_status_changed: true
          }
        end

        context 'when an existing collection is updated' do
          let(:collection_version) do
            create(:collection_version_with_collection, :deposited, :with_contact_emails, collection:)
          end

          it 'updates the collection' do
            patch "/collections/#{collection.id}", params: { collection: collection_params }
            expect(response).to redirect_to(collection)
            collection.reload
            expect(collection.depositors.size).to eq 6
            expect(collection.doi_option).to eq 'depositor-selects'
            expect(collection.email_depositors_status_changed).to be true
            expect(collection.custom_rights_statement_source_option).to eq 'entered_by_depositor'
            expect(collection.custom_rights_instructions_source_option).to eq 'default_instructions'
          end
        end

        context 'when the review workflow is set to disabled' do
          let(:collection) { create(:collection, :with_reviewers, managed_by: [user]) }
          let(:reviewed_by_attributes) do
            collection.reviewed_by.each_with_object({}).with_index do |(user, hash), index|
              hash[index] = { 'id' => user.id, 'sunetid' => user.sunetid, '_destroy' => 'false' }
            end
          end
          let(:collection_params) do
            {
              access: 'world',
              required_license: 'CC0-1.0',
              email_depositors_status_changed: true,
              review_enabled: 'false',
              reviewed_by_attributes:
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection:)
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
              email_depositors_status_changed: true,
              review_enabled: 'false'
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, :with_contact_emails, collection:)
            allow(CollectionObserver).to receive(:settings_updated)
          end

          it 'runs the observer method settings_updated' do
            patch "/collections/#{collection.id}",
                  params: { collection: collection_params, commit: save_draft_button }

            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection)
            expect(CollectionObserver).to have_received(:settings_updated)
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
          let(:depositor_attributes) do
            collection.depositors.each_with_object({}).with_index do |(user, hash), index|
              hash[index] = { 'id' => user.id, 'sunetid' => user.sunetid, '_destroy' => index.zero? ? 'false' : '1' }
            end
          end
          let(:collection_params) do
            {
              access: 'world',
              required_license: 'CC0-1.0',
              depositors_attributes: depositor_attributes,
              email_depositors_status_changed: true,
              review_enabled: 'true',
              reviewed_by_attributes: {
                '9998' => { 'sunetid' => reviewer.sunetid, 'id' => reviewer.id, '_destroy' => 'false' },
                '9997' => { 'sunetid' => reviewer2.sunetid, 'id' => reviewer2.id, '_destroy' => '1' }
              }
            }
          end

          before do
            create(:collection_version_with_collection, :version_draft, collection:)
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

        context 'when setting release option to immediate' do
          let(:collection) { create(:collection, managed_by: [user], release_option: 'delay') }
          let(:work) { create(:work, collection:) }

          let(:collection_params) do
            {
              release_option: 'immediate',
              access: 'world',
              required_license: 'CC0-1.0',
              email_depositors_status_changed: true,
              review_enabled: 'false'
            }
          end

          before do
            create(:collection_version_with_collection, collection:)
            create(:work_version_with_work, :embargoed, collection:, work:)
          end

          context 'when works with embargoes would be orphaned' do
            before do
              create(:work_version_with_work, :embargoed, collection:, work:)
            end

            it 'does not allow the change' do
              patch "/collections/#{collection.id}", params: { collection: collection_params, commit: deposit_button }
              expect(response).to have_http_status :unprocessable_entity
              expect(response.body).to include 'Release option cannot be set to immediate'
            end
          end

          context 'when works with embargoes would not be orphaned' do
            before do
              create(:work_version_with_work, :expired_embargo, collection:, work:)
            end

            it 'allows the change' do
              patch "/collections/#{collection.id}", params: { collection: collection_params, commit: deposit_button }
              expect(response).to have_http_status(:found)
              expect(response).to redirect_to(collection)
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
          create(:collection_version_with_collection, :version_draft, collection:)
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
