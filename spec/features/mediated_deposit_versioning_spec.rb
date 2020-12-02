# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a new version of a work in a collection using mediated deposit', js: true do
  let(:collection) { create(:collection, reviewers: [user], depositors: [user]) }
  let(:new_work_title) { 'I Appear To Have Changed' }
  let(:rejection_reason) { 'I do not like the color' }
  let(:newest_work_title) { 'Indigo is preferred' }
  let(:user) { create(:user) }
  # Work (and collection) needs to exist before user hits dashboard
  let!(:work) do
    create(:valid_deposited_work,
           depositor: user,
           collection: collection)
  end

  context 'when reviewer rejects, then approves work' do
    it 'works as expected' do
      sign_in user
      visit dashboard_path
      find("a[aria-label='Edit #{work.title}']").click
      fill_in 'Title of deposit', with: new_work_title
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content(new_work_title)
      expect(page).to have_content('Pending approval - Not deposited')

      visit dashboard_path
      within_table('Approvals') do
        click_link(new_work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Return').click
      fill_in 'reason', with: rejection_reason
      click_button('Submit')

      visit dashboard_path
      click_link new_work_title
      expect(page).to have_content(rejection_reason)

      # TODO: ask Amy if rejection should show up on the edit page
      find("a[aria-label='Edit #{new_work_title}']").click
      fill_in 'Title of deposit', with: newest_work_title
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content(newest_work_title)
      expect(page).to have_content('Pending approval - Not deposited')

      visit dashboard_path
      within_table('Approvals') do
        click_link(newest_work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Approve and deposit').click
      click_button('Submit')

      expect(page).to have_link(newest_work_title)
      click_link(newest_work_title)
      expect(page).to have_content('Deposit in progress')
    end
  end
end
