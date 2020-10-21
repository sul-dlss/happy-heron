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
        get "/collections/#{collection.id}/works/new"
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when Settings.allow_sdr_content_changes is' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

      # rubocop:disable RSpec/ExampleLength
      it 'false, it redirects and displays alert' do
        allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        get "/collections/#{collection.id}/works/new"
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end
      # rubocop:enable RSpec/ExampleLength

      it 'true, it does NOT display alert' do
        get "/collections/#{collection.id}/works/new"
        expect(response).to be_successful
        expect(response.body).not_to include alert_text
      end
    end
  end
end
