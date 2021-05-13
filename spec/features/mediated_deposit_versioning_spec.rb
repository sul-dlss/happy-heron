# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a new version of a work in a collection using mediated deposit', js: true do
  let(:collection) { create(:collection, reviewed_by: [user], depositors: [user], review_enabled: true) }
  let(:collection_version) { create(:collection_version, collection: collection) }
  let(:new_work_title) { 'I Appear To Have Changed' }
  let(:rejection_reason) { 'I do not like the color' }
  let(:newest_work_title) { 'Indigo is preferred' }
  let(:user) { create(:user) }
  let(:contact_email) { build(:contact_email) }
  # Work, WorkVersion, and Collection need to exist before user hits dashboard
  let!(:work_version) { create(:valid_deposited_work_version, contact_emails: [contact_email], work: work) }
  let(:work) { create(:work, druid: 'druid:bc123df4567', depositor: user, collection: collection) }

  before do
    collection.update(head: collection_version)
    work.update(head: work_version)
    create(:attached_file, :with_file, work_version: work_version)
  end

  context 'when reviewer rejects, then approves work' do
    it 'works as expected' do
      sign_in user
      visit dashboard_path
      find("a[aria-label='Edit #{work_version.title}']").click

      fill_in "What's changing?", with: 'Fixing title per request'

      fill_in 'Title of deposit', with: new_work_title
      check 'I agree to the SDR Terms of Deposit'

      click_button 'Submit for approval'

      expect(page).to have_content 'You have successfully submitted your deposit'
      click_link 'Return to dashboard'

      within_table('Approvals') do
        click_link(new_work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Return').click
      fill_in 'reason', with: rejection_reason
      click_button('Submit')

      visit dashboard_path
      within('.collections') do
        click_link new_work_title
      end
      expect(page).to have_content(rejection_reason)

      find("a[aria-label='Edit #{new_work_title}']").click
      fill_in 'Title of deposit', with: newest_work_title
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Submit for approval'

      expect(page).to have_content 'You have successfully submitted your deposit'
      click_link 'Return to dashboard'

      within_table('Approvals') do
        click_link(newest_work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Approve and deposit').click
      click_button 'Submit'

      within_table(collection_version.name) do
        expect(page).to have_link(newest_work_title)
        click_link(newest_work_title)
      end
      expect(page).to have_content('Deposit in progress')
    end
  end
end
