# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts', type: :request do
  describe 'GET /accounts/:id' do
    let(:user) { create(:user) }

    context 'with unauthenticated user' do
      before do
        sign_out
      end

      it 'redirects from /collections/new to login URL' do
        get '/accounts/fred'
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with an authenticated user who is not in any application workgroups' do
      before do
        sign_in user, groups: ['sdr:baz']
      end

      it 'is unauthorized' do
        get '/accounts/fred'
        expect(response).to redirect_to(:root)
      end
    end

    context 'with an authenticated collection creator' do
      let(:user) { create(:user) }

      before do
        sign_in user, groups: ['dlss:hydrus-app-collection-creators']
      end

      it 'displays the data' do
        get '/accounts/jcoyne85'
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq '{"name":"Coyne, Justin Michael",' \
                                    '"description":"Digital Library Systems and Services, ' \
                                    'Digital Library Software Engineer - Web \\u0026 Infrastructure"}'
      end
    end
  end
end
