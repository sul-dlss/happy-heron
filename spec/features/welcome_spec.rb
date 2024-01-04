# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Welcome page' do
  let(:user) { create(:user) }

  context 'when authenticated but not authorized', :js do
    before do
      sign_in user
      allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
    end

    it 'displays contact form' do
      visit '/'
      expect(page).to have_link('Logout')
      expect(page).to have_no_css '#breadcrumbs'
      expect(page.title).to eq 'SDR | Stanford Digital Repository' # Default title

      expect(page).to have_text 'It looks like this is your first time here.'
      select 'I want to become an SDR depositor', from: 'How can we help you?*'
      fill_in 'Describe your issue, question, or what you would like to deposit',
              with: 'Cat pictures'
      click_link_or_button 'Submit'

      expect(page).to have_text 'Help request successfully sent'
    end
  end

  context 'when unauthenticated' do
    before do
      sign_out
    end

    it 'displays login link' do
      visit '/'
      expect(page).to have_link('Login')
      expect(page).to have_no_css '#breadcrumbs'
      expect(page).to have_text 'Go to the SDR Dashboard'
    end
  end
end
