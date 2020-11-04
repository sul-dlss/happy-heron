# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new collection and deposit to it', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
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

      click_button '+ Deposit to this collection' # , match: :first

      expect(page).to have_content 'What type of content will you deposit?'
      find('label', text: 'Sound').click

      check 'Course/instruction'
      check 'Poetry reading'

      click_button 'Continue'

      expect(page).to have_content 'Deposit your work'

      # Test client-side validation messages
      fill_in 'Publication year', with: '2021'
      fill_in 'Created year', with: '999'
      click_button 'Deposit'
      expect(page).to have_content(
        "Publication year must be between #{Settings.earliest_publication_year} and #{Time.zone.today.year}"
      )
      expect(page).to have_content(
        "Created year must be between #{Settings.earliest_created_year} and #{Time.zone.today.year}"
      )
      fill_in 'Created year', with: ''
      # End of validation testing, continue filling out deposit form

      fill_in 'Title of deposit', with: 'My Title'
      fill_in 'Contact email', with: user.email

      fill_in 'Publication year', with: '2020'
      select 'February', from: 'Publication month'

      choose 'Date range'

      fill_in 'Created range start year', with: '2020'
      select 'March', from: 'Created range start month'
      select '6', from: 'Created range start day'
      fill_in 'Created range end year', with: '2020'
      select 'October', from: 'Created range end month'
      select '30', from: 'Created range end day'

      fill_in 'Abstract', with: 'Whatever'
      check 'Musical notation'

      fill_in 'Keywords', with: 'Springs'
      blur_from 'work_keywords'

      fill_in 'Citation for this deposit (optional)', with: 'Whatever'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content('title = My Title')
      expect(page).to have_content('work_type = sound')
      expect(page).to have_content('subtype = ["Course/instruction", "Musical notation", "Poetry reading"]')
      expect(page).to have_content("contact_email = #{user.email}")
      expect(page).to have_content('created_edtf = 2020-03-06/2020-10-30')
      expect(page).to have_content('abstract = Whatever')
      expect(page).to have_content('citation = Whatever')
      expect(page).to have_content('license = CC-PDDC')
      expect(page).to have_content('agree_to_terms = true')
      expect(page).to have_content('state = first_draft')
      expect(page).to have_content('collection_id = ')
    end
  end

  context 'when unsuccessful' do
    let(:collection) { create(:collection, depositors: [user]) }

    it 'does not submit' do
      visit "/collections/#{collection.id}/works/new?work_type=text"
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
