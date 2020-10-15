# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new work', js: true do
  let(:collection) { create(:collection) }
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when successful deposit' do
    it 'deposits and renders work show page' do
      visit "/collections/#{collection.id}/works/new"
      expect(page).to have_content('Deposit your work')

      fill_in 'Title of deposit', with: 'My Title'
      fill_in 'Contact e-mail', with: user.email
      fill_in 'Date created', with: '01/01/2020'
      fill_in 'Abstract', with: 'Whatever'
      fill_in 'Citation', with: 'Whatever'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content('title = My Title')
      expect(page).to have_content("contact_email = #{user.email}")
      expect(page).to have_content('created_etdf = 01/01/2020')
      expect(page).to have_content('abstract = Whatever')
      expect(page).to have_content('citation = Whatever')
      expect(page).to have_content('license = Copyleft')
      expect(page).to have_content('agree_to_terms = true')
      expect(page).to have_content('state = first_draft')
      expect(page).to have_content("collection_id = #{collection.id}")
    end
  end

  context 'when unsuccessful' do
    it 'does not submit' do
      visit "/collections/#{collection.id}/works/new"
      expect(page).to have_content('Deposit your work')

      fill_in 'Title of deposit', with: 'My Title'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).not_to have_content('title = My Title')
      expect(page).not_to have_content('agree_to_terms = true')
      expect(page).to have_content('Deposit your work')
    end
  end
end
