# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a collection report', :js do
  let(:user) { create(:user) }

  context 'when user is not an application admin' do
    before do
      sign_in user
    end

    it 'is forbidden' do
      visit new_admin_collection_report_path
      expect(page).to have_content 'You are not authorized to perform the requested action'
    end
  end

  context 'when no results are found' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows error' do
      visit new_admin_collection_report_path
      click_link_or_button 'Submit'

      expect(page).to have_content 'No results'
    end
  end

  context 'when results are found' do
    before do
      create(:collection_version_with_collection, state: 'deposited').collection

      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'allows report download' do
      visit new_admin_collection_report_path
      click_link_or_button 'Submit'

      click_link_or_button 'Download'
      expect(page.response_headers['content-type']).to match 'text/csv'
      expect(page.response_headers['content-disposition']).to match(/attachment; filename="collections_report.csv"/)
    end
  end
end
