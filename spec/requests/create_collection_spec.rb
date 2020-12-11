# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection' do
  let(:collection) { create(:collection) }
  let(:deposit_button) { 'Deposit' }
  let(:save_draft_button) { 'Save as draft' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with an authenticated user who is not in any application workgroups' do
    let(:user) { create(:user) }
    let(:alert_text) { 'You are not authorized to perform the requested action' }

    before do
      sign_in user, groups: ['sdr:baz']
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

    describe 'create' do
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
        let(:collection_params) do
          {
            name: 'My Test Collection',
            description: 'This is a very good collection.',
            contact_email: user.email,
            access: 'world',
            manager_sunets: user.sunetid,
            depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi',
            email_when_participants_changed: true,
            email_depositors_status_changed: true,
            'release_option' => 'delay',
            'release_date(1i)' => '2020',
            'release_date(2i)' => '7',
            'release_date(3i)' => '14',
            'release_duration' => '1 month',
            related_links_attributes: related_links
          }
        end

        it 'creates a new collection' do
          post '/collections', params: { collection: collection_params, commit: deposit_button }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(dashboard_path)
          collection = Collection.last
          expect(collection.depositors.size).to eq 6
          expect(collection.depositors).to all(be_kind_of(User))
          expect(collection.depositors).to include(User.find_by!(email: 'maya.aguirre@stanford.edu'))
          expect(collection.managers).to eq [user]
          expect(collection.email_when_participants_changed).to eq true
          expect(collection.email_depositors_status_changed).to eq true
          expect(collection.related_links.size).to eq 2
          expect(collection.related_links).to all(be_kind_of(RelatedLink))
          expect(collection.release_option).to eq 'delay'
          expect(collection.release_date).to eq Date.parse('2020-7-14')
        end

        it 'sends emails to depositors when a new collection is created and deposited' do
          expect { post '/collections', params: { collection: collection_params, commit: deposit_button } }
            .to change { ActionMailer::Base.deliveries.count }.by(collection.depositors.size) # depositor emails sent
        end

        context 'when overriding manager list and review workflow defaults' do
          let(:review_workflow_params) do
            {
              manager_sunets: 'maya.aguirre,jcairns',
              review_enabled: 'true',
              reviewer_sunets: 'maya.aguirre, jcairns,faridz'
            }
          end

          before { collection_params.merge!(review_workflow_params) }

          it 'sets the managers and reviewers fields' do
            post '/collections', params: { collection: collection_params, commit: deposit_button }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            collection = Collection.last
            expect(collection.managers.map(&:sunetid)).to eq ['maya.aguirre', 'jcairns']
            expect(collection.reviewers.map(&:email)).to eq %w[maya.aguirre@stanford.edu
                                                               jcairns@stanford.edu faridz@stanford.edu]
          end
        end

        context 'when review workflow is disabled' do
          let(:review_workflow_params) do
            {
              review_enabled: 'false',
              reviewer_sunets: 'maya.aguirre ,jcairns , faridz'
            }
          end

          before { collection_params.merge!(review_workflow_params) }

          it 'nils out the reviewers field' do
            post '/collections', params: { collection: collection_params, commit: deposit_button }
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(dashboard_path)
            collection = Collection.last
            expect(collection.reviewers).to be_empty
          end
        end

        context 'with empty fields' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_email: '',
              manager_sunets: user.sunetid,
              access: 'world',
              depositor_sunets: ''
            }
          end

          it 'saves the draft collection' do
            post '/collections', params: { collection: draft_collection_params, commit: save_draft_button }
            collection = Collection.last
            expect(collection.name).to be_empty
            expect(collection.depositors.size).to eq 0
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(collection_path(collection))
          end
        end

        context 'with depositors filled in' do
          let(:draft_collection_params) do
            {
              name: '',
              description: '',
              contact_email: '',
              manager_sunets: user.sunetid,
              access: 'world',
              depositor_sunets: 'maya.aguirre,jcairns, cchavez, premad, giancarlo, zhengyi'
            }
          end

          it 'does not send depositor emails when a new collection is created and saved as draft' do
            expect { post '/collections', params: { collection: draft_collection_params, commit: save_draft_button } }
              .to change { ActionMailer::Base.deliveries.count }.by(0) # NO depositor emails sent
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
          post '/collections', params: { collection: collection_params, format: :json, commit: deposit_button }
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json['name']).to eq ["can't be blank"]
        end
      end
    end
  end
end
