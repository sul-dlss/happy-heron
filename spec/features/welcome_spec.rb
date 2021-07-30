# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Welcome page' do
  let(:user) { create(:user) }

  context 'when authenticated' do
    before do
      sign_in user
      allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
    end

    it 'displays logout link' do
      visit '/'
      expect(page).to have_link('Logout')
      expect(page).not_to have_selector '#breadcrumbs'
      expect(page.title).to eq 'SDR | Stanford Digital Repository' # Default title
    end
  end

  context 'when unauthenticated' do
    before do
      sign_out
    end

    it 'displays login link' do
      visit '/'
      expect(page).to have_link('Login')
      expect(page).not_to have_selector '#breadcrumbs'
    end
  end
end
