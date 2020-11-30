# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a work in a collection using mediated deposit', js: true do
  # Collection needs to exist before user hits dashboard
  let!(:collection) { create(:collection, reviewers: [user], depositors: [user]) }
  let(:user) { create(:user) }
  let(:work_title) { 'Mediate this!' }

  context 'when reviewer approves work' do
    # NOTE: added this spec alongside mediated_deposit_versioning_spec but this
    #       spec flaps due (?) to client validation, so marking as xit for now
    xit 'works as expected' do
      sign_in user
      visit dashboard_path
      find("button[data-destination='/collections/#{collection.id}/works/new']").click
      find('label', text: 'Text').click
      click_button 'Continue'
      attach_file(Rails.root.join('spec/fixtures/files/sul.svg')) do
        click_button('Choose files')
      end
      expect(page).to have_content('sul.svg')
      fill_in 'Title of deposit', with: work_title
      fill_in 'Contact email', with: user.email
      fill_in 'First name', with: 'Contributor First Name'
      fill_in 'Last name', with: 'Contributor Last Name'
      fill_in 'Abstract', with: 'Whatever'
      fill_in 'Keywords', with: 'Springs'
      blur_from 'work_keywords'
      check 'I agree to the SDR Terms of Deposit'
      click_button 'Deposit'

      expect(page).to have_content(work_title)
      expect(page).to have_content('Pending approval - Not deposited')

      visit dashboard_path
      within_table('Approvals') do
        click_link(work_title)
      end
      expect(page).to have_content('Review all details below, then approve or return this deposit')
      find('label', text: 'Approve and deposit').click
      click_button('Submit')

      expect(page).to have_link(work_title)
      click_link(work_title)
      expect(page).to have_content('Deposit in progress')
    end
  end
end
