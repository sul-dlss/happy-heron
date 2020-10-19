# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new collection and deposit to it', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'when successful deposit' do
    let(:collection_attrs) { attributes_for(:collection) }

    it 'deposits and renders work show page' do
      visit dashboard_path

      click_link '+ Create a new collection'

      fill_in 'Collection name', with: collection_attrs.fetch(:name)
      fill_in 'Description', with: collection_attrs.fetch(:description)
      fill_in 'Contact email', with: collection_attrs.fetch(:contact_email)
      click_button 'Deposit'

      click_link '+ Deposit to this collection' # , match: :first
      expect(page).to have_content 'Deposit your work'

      fill_in 'Title of deposit', with: 'My Title'
      fill_in 'Contact email', with: user.email
      fill_in 'Date created', with: '01/01/2020'
      fill_in 'Abstract', with: 'Whatever'
      fill_in 'Citation', with: 'Whatever'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content('title = My Title')
      expect(page).to have_content("contact_email = #{user.email}")
      expect(page).to have_content('created_edtf = 01/01/2020')
      expect(page).to have_content('abstract = Whatever')
      expect(page).to have_content('citation = Whatever')
      expect(page).to have_content('license = Copyleft')
      expect(page).to have_content('agree_to_terms = true')
      expect(page).to have_content('state = first_draft')
      expect(page).to have_content('collection_id = ')
    end
  end

  context 'when unsuccessful' do
    let(:collection) { create(:collection) }

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
