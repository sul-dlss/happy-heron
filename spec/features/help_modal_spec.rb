# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Help modal', js: true do
  let(:user) { build(:user) }

  context 'when authenticated' do
    before do
      sign_in user
    end

    it 'opens modal, enters text, and submits query' do
      visit '/'
      click_link 'Help'
      within '#contactUsModal' do
        expect(page).to have_content 'Required fields'
        # Email is pre-populated from user
        expect(page).to have_field('What is your email address?*', with: user.email)
        # Fills in remaining fields
        fill_in 'What is your name?', with: 'User One'
        fill_in 'What is your Stanford affiliation/department?', with: 'SUL'
        select 'I want to ask a question', from: 'How can we help you?*'
        fill_in 'Describe your issue, question, or what you would like to deposit', with: 'A question for the ages'
        click_button 'Submit'
        expect(page).to have_content 'Your message has been sent to the SDR team. We will respond to you soon.'
      end
    end
  end

  context 'when unauthenticated' do
    let(:reason) { 'Would like deposit medical file' }

    before do
      sign_out
    end

    it 'opens modal, enters data, and submits query' do
      visit '/'
      click_link 'Help'
      # Selected for unauthenticated users
      expect(page).to have_select('How can we help you?*', selected: 'I want to become an SDR depositor')
      fill_in 'What is your name?', with: 'Dana Scully'
      fill_in 'What is your email address?*', with: 'dscully@stanford.edu'
      fill_in 'What is your Stanford affiliation/department?', with: 'Lane Medical Library'
      fill_in 'Describe your issue, question, or what you would like to deposit', with: reason
      click_button 'Submit'
      expect(page).to have_content 'Your message has been sent to the SDR team. We will respond to you soon.'
    end
  end
end
