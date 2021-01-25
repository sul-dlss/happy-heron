# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a draft work', js: true do
  let(:depositor) { create(:user) }
  let!(:work) do
    create(:work, :with_keywords, :with_attached_file,
           work_type: 'other', subtype: ['Graphic novel'], depositor: depositor)
  end

  before do
    work.collection.depositors = [depositor]
    sign_in depositor
  end

  context 'when successful deposit' do
    it 'deposits and renders work show page' do
      visit dashboard_path

      within('#deposits-in-progress') do
        click_link work.title
      end

      expect(page).to have_content work.title

      # TODO: we should be able to remove this once accepting is persisted.
      # See https://github.com/sul-dlss/happy-heron/issues/243
      check 'I agree to the SDR Terms of Deposit'

      expect(page).to have_content(work.attached_files.first.filename.to_s)
      # File removal should not raise an error
      find('button.dz-remove').click

      # Test validation
      fill_in 'Other', with: ''
      click_button 'Deposit'
      expect(page).to have_content("You must provide a subtype for works of type 'Other'")
      # End of validation testing

      fill_in 'Other', with: 'Comic book'
      click_button 'Deposit'

      expect(page).to have_content('Test title')
      # Attached file should now be gone
      expect(page).not_to have_content(work.attached_files.first.filename.to_s)
    end

    it 'shows a confirmation if you cancel the deposit and goes back if confirmed' do
      visit dashboard_path

      within('#deposits-in-progress') do
        click_link work.title
      end

      accept_confirm do
        click_link 'Cancel'
      end

      expect(page).to have_current_path(collection_works_path(work.collection))
    end

    it 'shows a confirmation if you cancel the deposit and stays on the page if not confirmed' do
      visit dashboard_path

      within('#deposits-in-progress') do
        click_link work.title
      end

      dismiss_confirm do
        click_link 'Cancel'
      end

      expect(page).to have_current_path(edit_work_path(work))
    end
  end
end
