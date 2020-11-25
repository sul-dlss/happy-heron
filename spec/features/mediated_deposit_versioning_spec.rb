# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a new version of a work in a collection using mediated deposit', js: true do
  let(:collection) { create(:collection, reviewers: [user], depositors: [user]) }
  let(:new_work_title) { 'I Appear To Have Changed' }
  let(:user) { create(:user) }
  # Work (and collection) needs to exist before user hits dashboard
  let!(:work) do
    create(:valid_deposited_work,
           depositor: user,
           collection: collection)
  end

  context 'when reviewer approves work' do
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
      within('section#approvals') do
        click_link(new_work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Approve and deposit').click
      click_button('Submit')

      expect(page).to have_link(new_work_title)
      click_link(new_work_title)
      expect(page).to have_content('Deposit in progress')
    end
  end
end
