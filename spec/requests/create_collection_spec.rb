# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection' do
  let(:collection) { create(:collection) }
  let(:deposit_button) { 'Deposit' }
  let(:save_draft_button) { 'Save as draft' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/new to login URL' do
      get new_first_draft_collection_path
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

    describe 'show the form' do
      it 'does not authorize GETs to /first_draft_collections/new' do
        get new_first_draft_collection_path
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end
    end

    describe 'save the form' do
      it 'does not allow the user to save a collection' do
        post first_draft_collections_path, params: { collection: { should_not: 'even read these params' } }
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end
    end
  end

  context 'with an authenticated collection creator' do
    let(:user) { create(:user) }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    describe 'shows the form for a new object' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

      context 'when content changes are not allowed' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        end

        it 'redirects and displays alert' do
          get new_first_draft_collection_path
          expect(response).to redirect_to(:root)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include alert_text
        end
      end

      context 'when content changes are allowed' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
        end

        it 'does NOT display alert' do
          get new_first_draft_collection_path
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include alert_text
        end
      end
    end

    describe 'save the form' do
      context 'when collection saves' do
        let(:related_links) do
          {
            '0' =>
            { '_destroy' => 'false', 'link_title' => 'link 1', 'url' => 'https://example.com' },
            '999' =>
            { '_destroy' => '1', 'link_title' => 'link 2', 'url' => 'https://example.com' },
            '1002' =>
            { '_destroy' => 'false', 'link_title' => 'link 3', 'url' => 'https://example.com' }
          }
        end

        let(:contact_emails) do
          {
            '0' =>
            { '_destroy' => 'false', email: user.email },
            '999' =>
            { '_destroy' => 'false', email: 'contact_email@example.com' }
          }
        end
        let(:next_year) { Time.zone.today + 1.year }

        let(:no_contact_emails) do
          { '0' => { '_destroy' => 'false', email: '' } }
        end

        let(:collection_params) do
          {
            name: 'My Test Collection',
            description: 'This is a very good collection.',
            access: 'world',
            managed_by_attributes: { '9999' => { 'sunetid' => user.sunetid, '_destroy' => 'false' } },
            depositors_attributes: {
              '9999' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
              '9998' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
              '9997' => { 'sunetid' => 'cchavez', '_destroy' => 'false' },
              '9996' => { 'sunetid' => 'premad', '_destroy' => 'false' },
              '9995' => { 'sunetid' => 'giancarlo', '_destroy' => 'false' },
              '9994' => { 'sunetid' => 'zhengyi', '_destroy' => 'false' }
            },
            email_when_participants_changed: true,
            email_depositors_status_changed: true,
            license_option: 'required',
            required_license: 'CC0-1.0',
            'release_option' => 'delay',
            'release_duration' => '1 year',
            doi_option: 'depositor-selects',
            contact_emails_attributes: contact_emails,
            related_links_attributes: related_links
          }
        end

        it 'creates a new collection' do
          post first_draft_collections_path, params: { collection: collection_params, commit: deposit_button }
          collection = Collection.last
          collection_version = collection.head

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(collection_path(collection))
          expect(collection.depositors.size).to eq 6
          expect(collection.depositors).to all(be_a(User))
          expect(collection.depositors).to include(User.find_by!(email: 'maya.aguirre@stanford.edu'))
          expect(collection.managed_by).to eq [user]
          expect(collection.email_when_participants_changed).to be true
          expect(collection.email_depositors_status_changed).to be true
          expect(collection.release_option).to eq 'delay'
          expect(collection.release_date).to eq next_year
          expect(collection.doi_option).to eq 'depositor-selects'
          expect(collection_version.contact_emails.size).to eq 2
          expect(collection_version.contact_emails).to all(be_a(ContactEmail))
          expect(collection_version.related_links.size).to eq 2
          expect(collection_version.related_links).to all(be_a(RelatedLink))
        end

        it 'sends emails to depositors when a new collection is created and deposited' do
          expect do
            post first_draft_collections_path, params: { collection: collection_params, commit: deposit_button }
          end.to change { ActionMailer::Base.deliveries.count }.by(collection.depositors.size) # depositor emails sent
        end

        context 'when overriding manager list and review workflow defaults' do
          let(:review_workflow_params) do
            {
              managed_by_attributes: {
                '9998' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
                '9999' => { 'sunetid' => 'jcairns', '_destroy' => 'false' }
              },
              review_enabled: 'true',
              reviewed_by_attributes: {
                '9998' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
                '9999' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
                '9997' => { 'sunetid' => 'faridz', '_destroy' => 'false' }
              }
            }
          end

          before { collection_params.merge!(review_workflow_params) }

          it 'sets the managers and reviewers fields' do
            post first_draft_collections_path, params: { collection: collection_params, commit: deposit_button }
            collection = Collection.last
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection_path(collection))
            expect(collection.managed_by.map(&:sunetid)).to contain_exactly('maya.aguirre', 'jcairns')
            expect(collection.reviewed_by.map(&:email)).to contain_exactly('maya.aguirre@stanford.edu',
                                                                           'jcairns@stanford.edu',
                                                                           'faridz@stanford.edu')
          end
        end

        context 'when review workflow is disabled' do
          let(:review_workflow_params) do
            {
              review_enabled: 'false',
              reviewed_by_attributes: {
                '9998' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
                '9999' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
                '9997' => { 'sunetid' => 'faridz', '_destroy' => 'false' }
              }
            }
          end

          before { collection_params.merge!(review_workflow_params) }

          it 'nils out the reviewers field' do
            post first_draft_collections_path, params: { collection: collection_params, commit: deposit_button }
            collection = Collection.last
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection_path(collection))
            expect(collection.reviewed_by).to be_empty
          end
        end

        context 'with empty fields' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_emails_attributes: no_contact_emails,
              access: 'world'
            }
          end

          it 'saves the draft collection' do
            post first_draft_collections_path,
                 params: { collection: draft_collection_params, commit: save_draft_button }
            expect(response).to have_http_status(:found)
            collection = Collection.last
            collection_version = collection.head
            expect(collection_version.name).to be_empty
            expect(collection.depositors.size).to eq 0
            expect(response).to redirect_to(collection_path(collection))
          end
        end

        context 'with an invalid contact email' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_emails_attributes: { '0' => { '_destroy' => 'false', email: 'bogus' } },
              access: 'world'
            }
          end

          it 'saves the draft collection' do
            post first_draft_collections_path,
                 params: { collection: draft_collection_params, commit: save_draft_button }
            expect(response).to have_http_status(:found)
            collection = Collection.last
            collection_version = collection.head
            expect(collection_version.name).to be_empty
            expect(collection.depositors.size).to eq 0
            expect(response).to redirect_to(collection_path(collection))
          end
        end

        context 'with depositors filled in' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_emails_attributes: no_contact_emails,
              access: 'world',
              depositors_attributes: {
                '9999' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
                '9998' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
                '9997' => { 'sunetid' => 'cchavez', '_destroy' => 'false' },
                '9996' => { 'sunetid' => 'premad', '_destroy' => 'false' },
                '9995' => { 'sunetid' => 'giancarlo', '_destroy' => 'false' },
                '9994' => { 'sunetid' => 'zhengyi', '_destroy' => 'false' }
              }
            }
          end

          it 'does not send depositor emails when a new collection is created and saved as draft' do
            expect do
              post first_draft_collections_path,
                   params: { collection: draft_collection_params, commit: save_draft_button }
            end.not_to(change { ActionMailer::Base.deliveries.count }) # NO depositor emails sent
          end
        end

        context 'with duplicate depositors' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_emails_attributes: no_contact_emails,
              access: 'world',
              depositors_attributes: {
                '9999' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' },
                '9998' => { 'sunetid' => 'jcairns', '_destroy' => 'false' },
                '9997' => { 'sunetid' => 'maya.aguirre', '_destroy' => 'false' }
              }
            }
          end

          it 'removes the duplicates' do
            post first_draft_collections_path,
                 params: { collection: draft_collection_params, commit: save_draft_button }
            collection = Collection.last
            expect(collection.depositors.map(&:sunetid)).to contain_exactly('maya.aguirre', 'jcairns')
          end
        end
      end

      context 'when collection fails to save' do
        let(:collection_params) do
          {
            visibility: 'world'
          }
        end

        it 'renders the page again' do
          post first_draft_collections_path, params: { collection: collection_params, commit: deposit_button }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include 'is-invalid'
        end
      end
    end
  end
end
