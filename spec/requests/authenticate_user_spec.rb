# typed: false
# frozen_string_literal: true

require 'rails_helper'

# NOTE: in deployed environments, this interaction is handled by Apache and
#       Shibboleth in concert with the application
RSpec.describe 'Authenticate the user' do
  let(:collection) { create(:collection) }
  let(:default_host) { 'http://www.example.com/' } # host value comes from Rails defaults
  let(:user) { create(:user) }
  let(:work) { create(:work) }

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'allows GETs to /' do
      get '/'
      expect(response).to have_http_status(:success)
    end

    it 'redirects from /webauth/login to root without a cookie' do
      get '/webauth/login'
      expect(response).to have_http_status(:found)
      expect(response.headers['Set-Cookie']).to be_nil
      expect(response).to redirect_to(default_host)
    end

    it 'redirects from /webauth/logout to root' do
      get '/webauth/logout'
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(default_host)
    end

    it 'redirects from /collections/:collection_id/works/new to login URL' do
      get "/collections/#{collection.id}/works/new"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("#{default_host}webauth/login")
    end

    it 'allows GETs to /works/:work_id' do
      get "/works/#{work.id}"
      expect(response).to have_http_status(:success)
    end

    it 'redirects from /collections/new to login URL' do
      get '/collections/new'
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("#{default_host}webauth/login")
    end
  end

  context 'with authenticated user' do
    before do
      sign_in user
    end

    it 'allows GETs to /' do
      get '/'
      expect(response).to have_http_status(:success)
    end

    it 'redirects from /webauth/login to root with a cookie' do
      get '/webauth/login'
      expect(response).to have_http_status(:found)
      expect(response.headers['Set-Cookie']).to start_with('_happy_heron_session=')
      expect(response).to redirect_to(default_host)
    end

    it 'redirects from /webauth/logout to configured logout URL' do
      get '/webauth/logout'
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("#{default_host}Shibboleth.sso/Logout")
    end

    it 'allows GETs to /collections/:collection_id/works/new' do
      get "/collections/#{collection.id}/works/new"
      expect(response).to have_http_status(:success)
    end

    it 'allows GETs to /works/:work_id' do
      get "/works/#{work.id}"
      expect(response).to have_http_status(:success)
    end

    it 'allows GETs to /collections/new' do
      get '/collections/new'
      expect(response).to have_http_status(:success)
    end
  end
end
