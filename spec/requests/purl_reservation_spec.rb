# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reserve a PURL and flesh it out into a work (version)' do
  let(:collection) { create(:collection, :deposited, :with_depositors) }
  let(:user) { collection.depositors.first }
  let(:work_title) { 'Pearlescence: An Ontology' }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with an authenticated user' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    describe 'submit to the work creation route in PURL reservation mode' do
      let(:hidden_form_params) { { commit: 'Deposit', purl_reservation: 'true' } }

      it 'creates a stub work to get the PURL' do
        expect do
          post "/collections/#{collection.id}/works", params: hidden_form_params.merge({ work: { title: work_title } })
        end.to change(WorkVersion, :count).by(1)

        work_version = WorkVersion.find_by!(title: work_title)
        expect(work_version.purl_reservation?).to eq true
        expect(work_version.work.depositor).to eq user
        expect(response).to redirect_to(dashboard_path)
      end
    end

    describe 'choose a type for the reserved PURL' do
      let(:work) { create(:work, depositor: user, collection: collection) }

      # have to set this here (?), artifact of the circular relationship between works and work_versions
      before { work.update(head: work_version) }

      context 'when the work version still has no type info specified' do
        let!(:work_version) { create(:work_version, :purl_reserved, work: work) }

        it 'sets the type and subtype, then redirects to the work edit page' do
          patch "/works/#{work.id}/update_type", params: { work_type: 'text', subtype: ['Other spoken word'] }

          expect(work_version.reload.purl_reservation?).to eq false
          expect(work_version.work_type).to eq 'text'
          expect(work_version.subtype).to eq ['Other spoken word']
          expect(work_version.work.events.pluck(:event_type)).to include('type_selected')
          expect(response).to redirect_to("/works/#{work.id}/edit")
        end
      end

      context 'when the work version has already had a type chosen' do
        let(:work_version) { create(:work_version, work: work) }

        it 'returns the user to the dashboard with an explanatory error message' do
          patch "/works/#{work.id}/update_type", params: { work_type: 'text', subtype: ['Other spoken word'] }

          expect(response).to redirect_to('/dashboard')
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('Unexpected error attempting to edit PURL reservation')
        end
      end
    end
  end
end
