# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User return location' do
  let(:collection) { create(:collection, depositors: [user]) }
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when in session' do
    let(:return_to_url) { new_collection_work_url(collection, work_type: 'text') }

    it 'redirects to user_return_to URL' do
      add_to_session(user_return_to: return_to_url)
      visit '/webauth/login'
      expect(page.body).to include('Deposit your content')
      expect(page.current_url).to eq(return_to_url)
    end
  end
end
