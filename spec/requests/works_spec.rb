# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Works requests' do
  let(:work) { create(:work) }
  let(:collection) { create(:collection) }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'allows GETs to /works/:work_id' do
      get "/works/#{work.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    describe 'show a work' do
      it 'displays the work' do
        get "/works/#{work.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'new work form' do
      it 'renders the form' do
        get "/collections/#{collection.id}/works/new?work_type=video"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'video'
      end
    end

    context 'when Settings.allow_sdr_content_changes is' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

      it 'false, it redirects and displays alert' do
        allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        get "/collections/#{collection.id}/works/new?work_type=text"
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end

      it 'true, it does NOT display alert' do
        get "/collections/#{collection.id}/works/new?work_type=other"
        expect(response).to be_successful
        expect(response.body).not_to include alert_text
      end
    end

    describe 'create work' do
      let(:collection) { create(:collection) }
      let(:manager_role) { create(:role_term, label: 'manager') }
      let(:developer_role) { create(:role_term, label: 'developer') }

      let(:contributors) do
        [
          { '_destroy' => '1', 'first_name' => 'Justin',
            'last_name' => 'Coyne', 'role_term_id' => developer_role.id },
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'role_term_id' => developer_role.id },
          { '_destroy' => 'false', 'first_name' => 'Vivian',
            'last_name' => 'Wong', 'role_term_id' => manager_role.id }
        ]
      end
      let(:work_params) { attributes_for(:work).merge(contributors_attributes: contributors) }

      it 'displays the work' do
        post "/collections/#{collection.id}/works", params: { work: work_params }
        expect(response).to have_http_status(:found)
        work = Work.last
        expect(work.contributors.size).to eq 2
      end
    end
  end
end
