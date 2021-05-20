# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  describe 'GET /index' do
    let(:user) { create(:user) }
    let(:druid) { 'druid:jb558km1569' }

    before { sign_in user }

    context 'when a work exists with the druid' do
      let!(:work) { create(:work, druid: druid) }

      it 'redirects with js' do
        get "/search?q=#{druid}", xhr: true
        expect(response.body).to eq "window.location='/works/#{work.id}'"
      end
    end

    context "when a work doesn't exist with the druid" do
      it 'redirects with js' do
        get "/search?q=#{druid}", xhr: true
        expect(response).to be_not_found
      end
    end

    context "when the client doesn't send a 'q' parameter" do
      it 'raises ParameterMissing error' do
        expect { get '/search?foo=bar', xhr: true }.to raise_error ActionController::ParameterMissing
      end
    end
  end
end
