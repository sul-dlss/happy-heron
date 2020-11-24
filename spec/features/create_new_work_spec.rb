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

      expect(page).not_to have_css('input#subtype_other')
      find('label', text: 'Other').click
      expect(page).to have_css('input#subtype_other')
      find('label', text: 'Sound').click

      check 'Course/instruction'
      check 'Poetry reading'

      click_button 'Continue'

      expect(page).to have_content 'Deposit your content'

      # Test client-side validation messages
      fill_in 'Publication year', with: '2021'
      fill_in 'Created year', with: '999'
      click_button 'Deposit'
      expect(page).to have_content(
        "Publication year must be between #{Settings.earliest_year} and #{Time.zone.today.year}"
      )
      expect(page).to have_content(
        "Created year must be between #{Settings.earliest_year} and #{Time.zone.today.year}"
      )
      expect(page).to have_content('You must provide an abstract')

      fill_in 'Created year', with: ''
      fill_in 'Publication year', with: ''
      # End of client-side validation testing

      page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
        click_button('Choose files')
      end

      fill_in 'Title of deposit', with: 'My Title'
      fill_in 'Contact email', with: user.email

      fill_in 'First name', with: 'Contributor First Name'
      fill_in 'Last name', with: 'Contributor Last Name'

      # This is the div that contains the contributor remove button. The button
      # should NOT be rendered since there's one and only one contributor at
      # this point, which is not removable.
      within('div.contributors-container') do
        expect(page).not_to have_selector('button')
      end

      select 'Publisher', from: 'Role term'
      fill_in 'Name', with: 'Best Publisher'

      fill_in 'Publication year', with: '2020'
      select 'February', from: 'Publication month'

      choose 'Date range'

      fill_in 'Created range start year', with: '2020'
      select 'March', from: 'Created range start month'
      select '6', from: 'Created range start day'
      fill_in 'Created range end year', with: '2020'
      select 'October', from: 'Created range end month'
      select '30', from: 'Created range end day'
      select 'Everyone', from: 'Who can access?'

      fill_in 'Abstract', with: 'Whatever'
      check 'Musical notation'

      # fill_in 'Citation', with: 'Whatever'
      check 'I agree to the SDR Terms of Deposit'

      # Test remote form validation which only happens once client-side validation passes
      expect(page).not_to have_content('Please add at least one keyword')
      expect(page).not_to have_css('.keywords-container.is-invalid')
      expect(page).not_to have_css('.keywords-container.is-invalid ~ .invalid-feedback')

      click_button 'Deposit'

      expect(page).to have_content('Please add at least one keyword')
      expect(page).to have_css('.keywords-container.is-invalid')
      expect(page).to have_css('.keywords-container.is-invalid ~ .invalid-feedback')

      fill_in 'Keywords', with: 'Springs'
      blur_from 'work_keywords'

      expect(page).not_to have_content('Please add at least one keyword')
      expect(page).not_to have_css('.keywords-container.is-invalid')
      expect(page).not_to have_css('.keywords-container.is-invalid ~ .invalid-feedback')
      # End of remote form validation

      fill_in 'Citation for this deposit (optional)', with: 'Whatever'

      click_link 'Terms of Deposit'
      expect(page).to have_content(
        'the Depositor grants The Trustees of Leland Stanford Junior University'
      )
      find('.btn-close').click

      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content('My Title')
      expect(page).to have_link(Collection.last.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content('sound')
      expect(page).to have_content('Course/instruction, Musical notation, Poetry reading')
      expect(page).to have_content(user.email)
      expect(page).to have_content('Best Publisher')
      expect(page).to have_content('2020-03-06/2020-10-30')
      expect(page).to have_content('Whatever')
      expect(page).to have_content('CC-PDDC Public Domain Dedication and Certification')
    end
  end

  context 'when unsuccessful' do
    let(:collection) { create(:collection, depositors: [user]) }

    it 'does not submit' do
      visit "/collections/#{collection.id}/works/new?work_type=text"
      expect(page).to have_content('Deposit your content')

      fill_in 'Title of deposit', with: 'My Title'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).not_to have_content('My Title')
      expect(page).to have_content('Deposit your content')
    end
  end
end
