# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit page contents', js: true do
  let(:user) { create(:user) }
  let(:page_content) { PageContent.last }

  before { create(:page_content) }

  context 'when user is not an application admin' do
    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    it 'is forbidden to edit' do
      visit admin_page_content_index_path
      expect(page).to have_content 'You are not authorized to perform the requested action'
    end

    it 'shows the text on the home page' do
      visit root_path
      expect(page).to have_content page_content.value
    end

    it 'shows the text on the dashboard page' do
      visit dashboard_path
      expect(page).to have_content page_content.value
    end
  end

  context 'when user is an application admin' do
    let(:new_text) { 'Some new stuff is pretty cool!' }

    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
    end

    it 'shows the edit index page' do
      visit admin_page_content_index_path

      expect(page).to have_content 'Edit Page Content'
    end

    it 'allows the user to edit the text' do
      visit edit_admin_page_content_path(page_content)

      fill_in 'page_content_value', with: new_text
      check 'page_content_visible'
      click_button 'Save'

      expect(page).to have_content 'Home page message updated'

      visit root_path
      expect(page).to have_content(new_text)
    end

    it 'allows the user to hide the text' do
      visit edit_admin_page_content_path(page_content)

      uncheck 'page_content_visible'
      click_button 'Save'

      expect(page).to have_content 'Home page message updated'

      visit root_path
      expect(page).not_to have_content(page_content.value)
    end
  end
end
