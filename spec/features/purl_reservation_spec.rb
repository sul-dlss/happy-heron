# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reserve a PURL for a work in a deposited collection', js: true do
  let(:user) { create(:user) }
  let!(:collection) { create(:collection, :deposited, :depositor_selects_access, depositors: [user]) }
  let(:bare_druid) { 'bc123df4567' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:title) { 'my PURL reservation test' }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when a PURL is reserved successfully' do
    it 'deposits a placeholder work, and lists it on the dashboard with its PURL' do
      visit dashboard_path

      click_button 'Reserve a PURL'
      fill_in 'Enter a title for this deposit', with: title
      click_button 'Submit'

      expect(page).to have_content title
      expect(page).to have_content 'Reserving PURL'

      work_version = WorkVersion.find_by!(title: title)
      expect(work_version.work.collection).to eq collection
      expect(work_version.work.depositor).to eq user
      expect(work_version.work_type).to eq WorkType.purl_reservation_type.id

      # fake deposit completion
      DepositStatusJob.new.complete_deposit(work_version, druid)

      # this should be updated automatically
      expect(page).to have_content 'PURL Reserved'

      # getting the PURL to show up requires a page refresh
      visit dashboard_path
      expect(page).to have_content "https://purl.stanford.edu/#{bare_druid}"
    end
  end

  context 'when cancelling out of the PURL reservation dialog' do
    it 'clears any entered text and does not create a work ' do
      visit dashboard_path

      click_button 'Reserve a PURL'
      fill_in 'Enter a title for this deposit', with: title
      click_button 'Cancel'

      click_button 'Reserve a PURL'
      expect(page).not_to have_content title

      visit dashboard_path
      expect(page).not_to have_content title
      expect(WorkVersion.find_by(title: title)).to be nil
    end
  end
end
