# typed: false
# frozen_string_literal: true

require 'rails_helper'

# NOTE: While controller specs are generally frowned upon, and we have largely
#       leaned on request specs instead, testing session-related code was not
#       possible in a request spec, and this is application biz logic worth
#       testing.
RSpec.describe LoginController do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller.warden).to receive(:authenticate)
  end

  describe '#login' do
    it 'authenticates the user' do
      get :login
      expect(controller.warden).to have_received(:authenticate).with(scope: :user).once
    end

    it 'redirects to root URL' do
      get :login
      expect(response).to redirect_to(root_path)
    end

    context 'with referrer param' do
      let(:referrer_url) { 'http://example.edu/do_the_thing' }

      it 'redirects to referrer' do
        get :login, params: { referrer: referrer_url }
        expect(response).to redirect_to(referrer_url)
      end
    end

    context 'with user_return_to in session' do
      let(:return_to_url) { 'http://www.example.org/collections/1/works/new' }

      it 'redirects to user_return_to' do
        session[:user_return_to] = return_to_url
        get :login
        expect(response).to redirect_to(return_to_url)
      end
    end
  end
end
