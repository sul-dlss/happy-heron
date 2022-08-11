# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reserve a PURL and flesh it out into a work (version)' do
  let(:collection_version) { create(:collection_version, :deposited) }
  let(:collection) { create(:collection, :with_depositors, :with_default_license, head: collection_version) }
  let(:user) { collection.depositors.first }
  let(:work_title) { 'Pearlescence: An Ontology' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with an authenticated user' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    let(:form_params) { { work: { title: work_title } } }

    describe 'submit to the work creation route in PURL reservation mode' do
      context 'with valid params' do
        it 'creates a stub work to get the PURL' do
          expect do
            post "/collections/#{collection.id}/reservations", params: form_params
          end.to change(WorkVersion, :count).by(1)

          work_version = WorkVersion.find_by!(title: work_title)
          expect(work_version.purl_reservation?).to be true
          expect(work_version.work.depositor).to eq user
          expect(work_version.license).to eq 'CC-BY-4.0'
          expect(response).to redirect_to(dashboard_path)
        end
      end

      context 'with invalid params' do
        let(:work_title) { '  ' }

        it 'returns an error' do
          expect do
            post "/collections/#{collection.id}/reservations", params: form_params
          end.not_to change(WorkVersion, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    describe 'choose a type for the reserved PURL' do
      let(:work) { create(:work, owner: user, collection: collection) }

      # have to set this here (?), artifact of the circular relationship between works and work_versions
      before { work.update(head: work_version) }

      context 'when the work version still has no type info specified' do
        let!(:work_version) { create(:work_version, :purl_reserved, work: work) }

        it 'sets the type and subtype, then redirects to the work edit page' do
          patch "/reservations/#{work.id}", params: { work_type: 'text', subtype: ['Other spoken word'] }

          expect(work_version.reload.purl_reservation?).to be false
          expect(work_version.work_type).to eq 'text'
          expect(work_version.subtype).to eq ['Other spoken word']
          expect(work_version.work.events.pluck(:event_type)).to include('type_selected')
          expect(response).to redirect_to("/works/#{work.id}/edit")
        end
      end

      context 'when the work version has no type and is then given an invalid type' do
        let(:work_version) { create(:work_version, :purl_reserved, work: work) }

        it 'returns the user to the dashboard with an explanatory error message' do
          patch "/reservations/#{work.id}", params: { work_type: 'other', subtype: [] }

          expect(response).to redirect_to('/dashboard')
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid subtype value'
        end
      end

      context 'when the work version has already had a type chosen' do
        let(:work_version) { create(:work_version, work: work) }

        it 'redirects the user to the homepage with an explanatory error message' do
          patch "/reservations/#{work.id}", params: { work_type: 'text', subtype: ['Other spoken word'] }

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('You are not authorized to perform the requested action')
        end
      end
    end
  end
end
