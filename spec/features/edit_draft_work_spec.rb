# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a draft work', js: true do
  let(:depositor) { create(:user) }
  let!(:work_version) do
    create(:work_version, :with_keywords,
           work_type: 'other', subtype: ['Graphic novel'],
           state: 'version_draft', work:)
  end
  # create a collection that allows embargo access selection
  let(:collection) do
    create(:collection, :depositor_selects_access, :depositor_selects_release_date, managed_by: [depositor],
                                                                                    head: collection_version)
  end
  let(:collection_version) { create(:collection_version, :deposited) }
  let(:work) { create(:work, owner: depositor, collection:) }

  context 'when a user has previously accepted the terms of agreement less than 1 year ago' do
    before do
      depositor.update(last_work_terms_agreement: Time.zone.now.days_ago(2))
      work.update(head: work_version)
      create(:attached_file, :with_file, work_version:)
      work.collection.depositors = [depositor]
      sign_in depositor
    end

    context 'when successful deposit of "other" type work' do
      it 'deposits and renders work show page' do
        visit dashboard_path

        click_link 'Yes!'

        expect(page).to have_content work_version.title

        filename = work_version.attached_files.first.filename.to_s
        expect(page).to have_content(filename)
        # File removal should not raise an error
        find('button.dz-remove').click # rubocop:disable RSpec/Capybara/SpecificActions

        # Test validation
        fill_in 'Other', with: ''
        click_button 'Deposit'
        expect(page).to have_content("You must provide a subtype for works of type 'Other'")
        # End of validation testing

        # breadcrumbs showing
        within '#breadcrumbs' do
          expect(page).to have_content('Dashboard')
          expect(page).to have_content(work.collection.head.name)
          expect(page).to have_content(work_version.title)
          expect(page).to have_content('Edit')
        end

        expect(page).to have_content('Work subtypes')
        expect(page).not_to have_content('Work subtypes (optional)')

        fill_in "What's changing?", with: 'Fixing title per request'

        fill_in 'Other', with: 'Comic book'
        click_button 'Deposit'

        expect(page).to have_content('Test title')
        # Attached file should now be gone
        expect(page).not_to have_content(filename)
      end
    end

    it 'shows a confirmation if you cancel the deposit and goes back to work show page if confirmed' do
      visit dashboard_path

      click_link 'Yes!'
      fill_in 'Abstract', with: 'Change made'

      accept_confirm do
        click_link 'Cancel'
      end

      expect(page).to have_current_path(work_path(work))
    end

    it 'shows a confirmation if you cancel the deposit and stays on the page if not confirmed' do
      visit dashboard_path

      click_link 'Yes!'
      fill_in 'Abstract', with: 'Change made'

      dismiss_confirm do
        click_link 'Cancel'
      end

      expect(page).to have_current_path(edit_work_path(work))
    end

    context 'when successful deposit of "music" type work' do
      let(:work_version) do
        create(:valid_work_version, title: 'My Preprint/Data',
                                    work:,
                                    work_type: 'music',
                                    subtype: %w[Data Preprint])
      end

      it 'deposits and renders work show page' do
        visit dashboard_path

        click_link 'Yes!'

        expect(page).to have_content work_version.title
        expect(page).to have_content('Work subtypes')
        expect(page).to have_content('Select at least one term below')
        expect(find_by_id('work_subtype_preprint', visible: :all)).not_to be_visible
        expect(find_by_id('work_subtype_data')).to be_visible
        expect(find_by_id('work_subtype_data')).to be_checked
        click_link 'See more options'
        expect(find_by_id('work_subtype_preprint')).to be_visible
        expect(find_by_id('work_subtype_preprint')).to be_checked
        uncheck 'Preprint'
        check 'Technical report'
        click_link 'See fewer options'
        expect(find_by_id('work_subtype_preprint', visible: :all)).not_to be_visible

        click_button 'Deposit'

        expect(page).to have_content 'You have successfully deposited your work'
      end
    end
  end

  context 'when a user has never accepted the terms of agreement' do
    before do
      depositor.update(last_work_terms_agreement: nil)
      work.update(head: work_version)
      create(:attached_file, :with_file, work_version:)
      work.collection.depositors = [depositor]
      sign_in depositor
    end

    context 'when saving draft with invalid embargo date' do
      it 're-renders the page with an error message' do
        visit dashboard_path

        click_link 'Yes!'

        expect(page).to have_content work_version.title

        # ensure we do not agree to the terms!
        uncheck 'I agree to the SDR Terms of Deposit'

        # add bogus embargo date
        choose 'On this date'
        select (Time.zone.today.year + 1).to_s, from: 'work_embargo_year' # select next year (so always in the future)
        select '31', from: 'work_embargo_day' # and a bogus month and day combo
        select 'February', from: 'work_embargo_month'

        click_button 'Save as draft'

        # the page re-renders with the error message
        expect(page).to have_content('Embargo date must provide all date parts and must be a valid date')
      end
    end

    context 'when successful deposit of "other" type work' do
      it 'deposits and renders work show page' do
        visit dashboard_path

        click_link 'Yes!'

        expect(page).to have_content work_version.title

        # we need to agree to the terms once
        check 'I agree to the SDR Terms of Deposit'

        filename = work_version.attached_files.first.filename.to_s
        expect(page).to have_content(filename)
        # File removal should not raise an error
        find('button.dz-remove').click # rubocop:disable RSpec/Capybara/SpecificActions

        # Test validation
        fill_in 'Other', with: ''
        click_button 'Deposit'
        expect(page).to have_content("You must provide a subtype for works of type 'Other'")
        # End of validation testing

        # breadcrumbs showing
        within '#breadcrumbs' do
          expect(page).to have_content('Dashboard')
          expect(page).to have_content(work.collection.head.name)
          expect(page).to have_content(work_version.title)
          expect(page).to have_content('Edit')
        end

        expect(page).to have_content('Work subtypes')
        expect(page).not_to have_content('Work subtypes (optional)')

        fill_in "What's changing?", with: 'Fixing title per request'

        fill_in 'Other', with: 'Comic book'
        click_button 'Deposit'

        expect(page).to have_content('Test title')
        # Attached file should now be gone
        expect(page).not_to have_content(filename)
      end
    end
  end

  context 'when a user has previously accepted the terms of agreement over 1 year ago' do
    before do
      depositor.update(last_work_terms_agreement: Time.zone.now.years_ago(2))
      work.update(head: work_version)
      create(:attached_file, :with_file, work_version:)
      work.collection.depositors = [depositor]
      sign_in depositor
    end

    context 'when successful deposit of "other" type work' do
      it 'deposits and renders work show page' do
        visit dashboard_path

        click_link 'Yes!'

        expect(page).to have_content work_version.title

        # we need to agree to the terms once
        check 'I agree to the SDR Terms of Deposit'

        filename = work_version.attached_files.first.filename.to_s
        expect(page).to have_content(filename)
        # File removal should not raise an error
        find('button.dz-remove').click # rubocop:disable RSpec/Capybara/SpecificActions

        # Test validation
        fill_in 'Other', with: ''
        click_button 'Deposit'
        expect(page).to have_content("You must provide a subtype for works of type 'Other'")
        # End of validation testing

        # breadcrumbs showing
        within '#breadcrumbs' do
          expect(page).to have_content('Dashboard')
          expect(page).to have_content(work.collection.head.name)
          expect(page).to have_content(work_version.title)
          expect(page).to have_content('Edit')
        end

        expect(page).to have_content('Work subtypes')
        expect(page).not_to have_content('Work subtypes (optional)')

        fill_in "What's changing?", with: 'Fixing title per request'

        fill_in 'Other', with: 'Comic book'
        click_button 'Deposit'

        expect(page).to have_content('Test title')
        # Attached file should now be gone
        expect(page).not_to have_content(filename)
      end
    end
  end
end
