# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching for a DRUID', :js do
  let(:user) { create(:user) }

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden' do
      visit admin_druid_searches_path
      expect(page).to have_content 'You are not authorized to perform the requested action'
    end
  end

  context 'when druid is not found' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows error' do
      visit admin_druid_searches_path

      fill_in 'Enter DRUID', with: 'oops'
      click_link_or_button 'Search'

      expect(page).to have_content 'DRUID not found.'
    end
  end

  context 'when druid is found' do
    let(:work_version) { create(:work_version_with_work_and_collection, state: 'deposited') }
    let(:work) { work_version.work }
    let(:druid) { 'druid:bc123df4567' }

    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
      work.update(druid:)
    end

    it 'redirects to work' do
      visit admin_druid_searches_path

      fill_in 'Enter DRUID', with: work.druid
      click_link_or_button 'Search'
      expect(page).to have_current_path work_path(work_version.work), ignore_query: true
    end
  end
end
