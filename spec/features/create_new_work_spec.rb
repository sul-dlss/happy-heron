# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new work in a deposited collection', js: true do
  let(:user) { create(:user) }
  let(:collection_version) { create(:collection_version, :deposited, collection:) }
  let(:default_license) { 'CC0-1.0' }
  let(:collection) { create(:collection, :depositor_selects_access, depositors: [user], default_license:) }
  let(:second_email) { 'second@example.com' }

  before do
    collection.update(head: collection_version)
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when a user has previously accepted the terms of agreement less than 1 year ago' do
    before { user.update(last_work_terms_agreement: Time.zone.now.days_ago(2)) }

    context 'when successful deposit' do
      context 'with a user-supplied citation' do
        before do
          allow(OrcidService).to receive(:lookup).and_return(Dry::Monads::Result::Success.new(['Orcid First Name',
                                                                                               'Orcid Last Name']))
        end

        it 'deposits and renders work show page' do
          visit dashboard_path

          click_button '+ Deposit to this collection' # , match: :first

          expect(page).to have_content 'What type of content will you deposit?'

          expect(page).not_to have_css('input#subtype_other') # rubocop:disable RSpec/Capybara/SpecificMatcher
          find('label', text: 'Other').click
          expect(page).to have_css('input#subtype_other') # rubocop:disable RSpec/Capybara/SpecificMatcher
          find('label', text: 'Sound').click

          check 'Podcast'
          expect(page).not_to have_content('Poetry reading')
          click_link 'See more options'
          expect(page).to have_content('Poetry reading')
          check 'Poetry reading'
          click_link 'See fewer options'
          expect(page).not_to have_content('Poetry reading')

          click_button 'Continue'

          expect(page).to have_content 'Deposit your content'

          # On initial deposit, the version description is not available
          expect(page).not_to have_content "What's changing?"

          # breadcrumbs showing
          within '#breadcrumbs' do
            expect(page).to have_content('Dashboard')
            expect(page).to have_content('New deposit')
          end

          # Test client-side validation messages
          fill_in 'Publication year', with: '2049'
          fill_in 'Created year', with: '999'
          click_button 'Deposit'
          expect(page).to have_content(
            'must be after 1000'
          )
          expect(page).to have_content(
            'must be in the past'
          )
          expect(page).to have_content('You must provide an abstract')

          fill_in 'Created year', with: '2000'
          select 'February', from: 'Created month'
          select '31', from: 'Created day'
          expect(page).to have_content(
            'must be a valid day'
          )

          fill_in 'Created year', with: ''
          fill_in 'Publication year', with: ''
          select 'month', from: 'Created month'
          select 'day', from: 'Created day'

          choose 'work_upload_type_browser'
          page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
            click_button('Choose files')
          end
          expect(page).to have_css('div.dz-success-mark')
          page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
            click_button('Choose files')
          end

          expect(page).to have_content('Duplicate file')
          # remove the file which has the 'duplicate' error
          within('div.dz-error', visible: true) do
            find('.remove-file').click
          end
          expect(page).not_to have_content('Duplicate file')
          # End of client-side validation testing

          choose 'work_upload_type_browser'
          page.attach_file(Rails.root.join('spec/fixtures/files/favicon.ico')) do
            click_button('Choose files')
          end

          fill_in 'Title of deposit', with: 'My Title'
          fill_in 'Contact email', with: user.email

          within_section 'Authors to include in citation' do
            fill_in 'First name', with: 'Contributor First Name'
            fill_in 'Last name', with: 'Contributor Last Name'

            # Switch to an ORCID
            choose 'Enter author by ORCID iD'
            fill_in 'ORCID iD *', with: 'https://orcid.org/0000-0003-1527-0030'
            expect(page).to have_content('Name associated with this ORCID iD is Orcid First Name Orcid Last Name')

            # Switch to an organization
            select 'Publisher', from: 'Role term'
            fill_in 'Name', with: 'Best Publisher'
          end

          fill_in 'Publication year', with: '2020'
          select 'February', from: 'Publication month'

          check 'Enter a date range'

          fill_in 'Created range start year', with: '2020'
          select 'March', from: 'Created range start month'
          select '6', from: 'Created range start day'
          fill_in 'Created range end year', with: '2020'
          select 'October', from: 'Created range end month'
          select '30', from: 'Created range end day'
          select 'Everyone', from: 'Who can download the files?'

          fill_in 'Abstract', with: 'User provided abstract'
          check 'Oral history'

          click_button 'Deposit'

          expect(page).to have_content('At least one keyword is required. Each keyword must be unique.')

          fill_in 'Keyword', with: 'Springs'

          find('label.switch').click # Use auto-generated citation
          fill_in 'Provided citation', with: 'Citation from user input'

          click_button 'Deposit'

          expect(page).to have_content 'You have successfully deposited your work'
          click_link 'Return to dashboard'

          # We should not see the delete button for this work since it is not a draft
          expect(page).not_to have_selector("[aria-label='Delete #{WorkVersion.last.title}']")

          expect(page).to have_content('Deposit to this collection')
          click_link 'My Title'
          expect(page).to have_content('My Title')
          expect(page).to have_link(collection_version.name)
          expect(page).to have_content(user.email)
          expect(page).to have_content('Sound')
          expect(page).to have_content('Oral history, Podcast, Poetry reading')
          expect(page).to have_content('Best Publisher')
          expect(page).to have_content('2020-03-06 - 2020-10-30')
          expect(page).to have_content 'User provided abstract'
          expect(page).to have_content 'Citation from user input'
          expect(page).to have_content 'Everyone'
          expect(page).to have_content 'CC0-1.0'

          within('#filesTable') do
            # files are sorted alphabetically
            expect(all('tr')[1]).to have_content 'favicon.ico'
            expect(all('tr')[2]).to have_content 'sul.svg'
          end

          within '#events' do
            # New work gets a description of what's changed (except subtypes)
            changed = ['title of deposit modified', 'abstract modified', 'contact email modified', 'authors modified',
                       'publication date modified', 'creation date modified', 'keywords modified', 'citation modified',
                       'files added/removed']
            expect(page).to have_content changed.join(', '), count: 1
          end
        end
      end

      context 'with an auto generated citation' do
        it 'deposits and renders work show page' do
          visit dashboard_path

          click_button '+ Deposit to this collection'

          expect(page).to have_content 'What type of content will you deposit?'

          find('label', text: 'Data').click
          # check that modal doesn't display subtype that exactly matches the type
          click_link 'See more options'
          expect(page).not_to have_css('#subtype_Data')

          click_button 'Continue'

          choose 'work_upload_type_browser'
          page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
            click_button('Choose files')
          end
          sleep 1 # pause to ensure file upload completes before we proceed
          # see https://github.com/sul-dlss/happy-heron/issues/978
          # we were hoping the with block below would block until upload
          # completes, but it did not
          within '.dropzone-previews' do
            expect(page).to have_content('sul.svg')
          end

          fill_in 'Title of deposit', with: 'My Title'
          fill_in 'Contact email', with: user.email

          within_section 'Authors to include in citation' do
            fill_in 'First name', with: 'Michael'
            fill_in 'Last name', with: 'Keller'
          end

          fill_in 'Publication year', with: '2020'
          select 'February', from: 'Publication month'

          fill_in 'Abstract', with: 'User provided abstract'

          fill_in 'Keyword', with: 'Springs'

          click_button 'Deposit'

          expect(page).to have_content 'You have successfully deposited your work'
          click_link 'Return to dashboard'

          expect(page).to have_content('Deposit to this collection')
          click_link 'My Title'

          expect(page).to have_content "Keller, M. (#{Time.zone.today.year}). My Title. " \
                                       "Stanford Digital Repository. Available at #{WorkVersion::LINK_TEXT}. " \
                                       "#{WorkVersion::DOI_TEXT}"
        end
      end
    end

    context 'when unsuccessful' do
      let(:collection) { create(:collection, depositors: [user]) }

      it 'does not submit' do
        visit "/collections/#{collection.id}/works/new?work_type=text"
        expect(page).to have_content('Deposit your content')

        fill_in 'Title of deposit', with: 'My Title'
        click_button 'Deposit'

        expect(page).not_to have_content('My Title')
        expect(page).to have_content('Deposit your content')
      end
    end
  end

  context 'when a user has previously accepted the terms of agreement over 1 year ago and needs to re-accept them' do
    before do
      user.update(last_work_terms_agreement: Time.zone.now.years_ago(2))
    end

    context 'when successful deposit' do
      context 'with a user-supplied citation' do
        it 'deposits and renders work show page' do
          visit dashboard_path

          click_button '+ Deposit to this collection' # , match: :first

          expect(page).to have_content 'What type of content will you deposit?'

          expect(page).not_to have_css('input#subtype_other') # rubocop:disable RSpec/Capybara/SpecificMatcher
          find('label', text: 'Other').click
          expect(page).to have_css('input#subtype_other') # rubocop:disable RSpec/Capybara/SpecificMatcher
          find('label', text: 'Sound').click

          check 'Podcast'
          expect(page).not_to have_content('Poetry reading')
          click_link 'See more options'
          expect(page).to have_content('Poetry reading')
          check 'Poetry reading'
          click_link 'See fewer options'
          expect(page).not_to have_content('Poetry reading')

          click_button 'Continue'

          expect(page).to have_content 'Deposit your content'

          # On initial deposit, the version description is not available
          expect(page).not_to have_content "What's changing?"

          # breadcrumbs showing
          within '#breadcrumbs' do
            expect(page).to have_content('Dashboard')
            expect(page).to have_content('New deposit')
          end

          # Test client-side validation messages
          fill_in 'Publication year', with: '2049'
          fill_in 'Created year', with: '999'
          click_button 'Deposit'
          expect(page).to have_content(
            'must be after 1000'
          )
          expect(page).to have_content(
            'must be in the past'
          )
          expect(page).to have_content('You must provide an abstract')

          fill_in 'Created year', with: ''
          fill_in 'Publication year', with: ''

          choose 'work_upload_type_browser'
          page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
            click_button('Choose files')
          end
          expect(page).to have_css('div.dz-success-mark')
          page.attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
            click_button('Choose files')
          end

          click_button 'Deposit'
          # should not deposit but continue to show duplicate file error
          expect(page).to have_content('Duplicate file')
          # remove the file which has the 'duplicate' error
          within('div.dz-error', visible: true) do
            find('.remove-file').click
          end
          expect(page).not_to have_content('Duplicate file')
          # End of client-side validation testing

          fill_in 'Title of deposit', with: 'My Title'
          fill_in 'Contact email', with: user.email

          within_section 'Authors to include in citation' do
            fill_in 'First name', with: 'Contributor First Name'
            fill_in 'Last name', with: 'Contributor Last Name'

            select 'Publisher', from: 'Role term'
            fill_in 'Name', with: 'Best Publisher'
          end

          fill_in 'Publication year', with: '2020'
          select 'February', from: 'Publication month'

          check 'Enter a date range'

          fill_in 'Created range start year', with: '2020'
          select 'March', from: 'Created range start month'
          select '6', from: 'Created range start day'
          fill_in 'Created range end year', with: '2020'
          select 'October', from: 'Created range end month'
          select '30', from: 'Created range end day'
          select 'Everyone', from: 'Who can download the files?'

          fill_in 'Abstract', with: 'User provided abstract'
          check 'Oral history'

          click_button 'Deposit'

          expect(page).to have_content('At least one keyword is required. Each keyword must be unique.')

          fill_in 'Keyword', with: 'Springs'

          find('label.switch').click # Use auto-generated citation
          fill_in 'Provided citation', with: 'Citation from user input'

          # we need to agree to the terms of deposit once
          click_link 'Terms of Deposit'
          expect(page).to have_content(
            'the Depositor grants The Trustees of Leland Stanford Junior University'
          )
          find('.btn-close').click

          # we need to agree to the terms once
          check 'I agree to the SDR Terms of Deposit'

          click_button 'Deposit'

          expect(page).to have_content 'You have successfully deposited your work'
          click_link 'Return to dashboard'

          # We should not see the delete button for this work since it is not a draft
          expect(page).not_to have_selector("[aria-label='Delete #{WorkVersion.last.title}']")

          expect(page).to have_content('Deposit to this collection')
          click_link 'My Title'
          expect(page).to have_content('My Title')
          expect(page).to have_link(collection_version.name)
          expect(page).to have_content(user.email)
          expect(page).to have_content('Sound')
          expect(page).to have_content('Oral history, Podcast, Poetry reading')
          expect(page).to have_content('Best Publisher')
          expect(page).to have_content('2020-03-06 - 2020-10-30')
          expect(page).to have_content 'User provided abstract'
          expect(page).to have_content 'Citation from user input'
          expect(page).to have_content 'Everyone'
          expect(page).to have_content 'CC0-1.0'

          within '#events' do
            # New work gets a description of what's changed (except subtypes)
            changed = ['title of deposit modified', 'abstract modified', 'contact email modified', 'authors modified',
                       'publication date modified', 'creation date modified', 'keywords modified', 'citation modified',
                       'files added/removed']
            expect(page).to have_content changed.join(', '), count: 1
          end
        end
      end
    end
  end
end
