# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Works requests' do
  let(:work) { create(:work) }

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
      let(:collection) { create(:collection) }

      it 'renders the form' do
        get "/collections/#{collection.id}/works/new"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
