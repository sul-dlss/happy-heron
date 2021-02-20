# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a draft work', js: true do
  let(:depositor) { create(:user) }
  let!(:work_version) do
    create(:work_version, :with_keywords,
           work_type: 'other', subtype: ['Graphic novel'], work: work)
  end
  let(:collection) { create(:collection_version_with_collection).collection }
  let(:work) { create(:work, depositor: depositor, collection: collection) }

  before do
    work.update(head: work_version)
    create(:attached_file, :with_file, work_version: work_version)
    work.collection.depositors = [depositor]
    sign_in depositor
  end

  context 'when successful deposit of "other" type work' do
    it 'deposits and renders work show page' do
      visit dashboard_path

      click_link 'Yes!'

      expect(page).to have_content work_version.title

      # TODO: we should be able to remove this once accepting is persisted.
      # See https://github.com/sul-dlss/happy-heron/issues/243
      check 'I agree to the SDR Terms of Deposit'

      filename = work_version.attached_files.first.filename.to_s
      expect(page).to have_content(filename)
      # File removal should not raise an error
      find('button.dz-remove').click

      # Test validation
      fill_in 'Other', with: ''
      click_button 'Deposit'
      expect(page).to have_content("You must provide a subtype for works of type 'Other'")
      # End of validation testing

      # breadcrumbs showing
      find('#breadcrumbs') do |nav|
        expect(nav).to have_content('Dashboard')
        expect(nav).to have_content(work.collection.head.name)
        expect(nav).to have_content(work_version.title)
        expect(nav).to have_content('Edit')
      end

      expect(page).to have_content('Work types')
      expect(page).not_to have_content('Work types (optional)')

      fill_in 'Other', with: 'Comic book'
      click_button 'Deposit'

      expect(page).to have_content('Test title')
      # Attached file should now be gone
      expect(page).not_to have_content(filename)
    end
  end

  it 'shows a confirmation if you cancel the deposit and goes back if confirmed' do
    visit dashboard_path

    click_link 'Yes!'

    accept_confirm do
      click_link 'Cancel'
    end

    expect(page).to have_current_path(collection_works_path(work.collection))
  end

  it 'shows a confirmation if you cancel the deposit and stays on the page if not confirmed' do
    visit dashboard_path

    click_link 'Yes!'

    dismiss_confirm do
      click_link 'Cancel'
    end

    expect(page).to have_current_path(edit_work_path(work))
  end

  context 'when successful deposit of "music" type work' do
    let(:work_version) do
      create(:valid_work_version, title: 'My Preprint/Data',
                                  work: work,
                                  work_type: 'music',
                                  subtype: %w[Data Preprint])
    end

    it 'deposits and renders work show page' do
      visit dashboard_path

      click_link 'Yes!'

      expect(page).to have_content work_version.title
      expect(page).to have_content('Work types')
      expect(page).to have_content('Select at least one term below')
      expect(find('#work_subtype_preprint', visible: :all)).not_to be_visible
      expect(find('#work_subtype_data')).to be_visible
      expect(find('#work_subtype_data')).to be_checked
      click_link 'See more options'
      expect(find('#work_subtype_preprint')).to be_visible
      expect(find('#work_subtype_preprint')).to be_checked
      uncheck 'Preprint'
      check 'Technical report'
      click_link 'See fewer options'
      expect(find('#work_subtype_preprint', visible: :all)).not_to be_visible

      # TODO: we should be able to remove this once accepting is persisted.
      # See https://github.com/sul-dlss/happy-heron/issues/243
      check 'I agree to the SDR Terms of Deposit'

      click_button 'Deposit'

      expect(page).to have_content('My Preprint/Data')
      expect(page).to have_content('Data, Technical report')
    end
  end
end
