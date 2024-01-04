# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Automatically generate a citation', :js do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, release_option: 'depositor-selects', depositors: [user]) }
  let(:collection_version) { create(:collection_version, :deposited, collection:) }

  before do
    collection.update(head: collection_version)
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when year varies in automatic citation' do
    it 'default, publication, and embargo year in citation' do
      visit dashboard_path

      expect(page).to have_content collection_version.name

      click_link_or_button '+ Deposit to this collection'

      find('label', text: 'Image').click

      click_link_or_button 'Continue'

      expect(page).to have_content 'Deposit your content'

      within_section 'Authors to include in citation' do
        fill_in 'First name', with: 'Dana'
        fill_in 'Last name', with: 'Scully'
        blur_from 'Last name'
      end

      elem = page.find(id: 'work_citation_auto')

      # Default is the current year
      expect(elem.value).to have_content "Scully, D. (#{Time.zone.today.year})"

      # Change the embargo year
      choose 'On this date'
      select Time.zone.today.year + 1

      # Citation now is one year ahead of today
      expect(elem.value).to have_content "Scully, D. (#{Time.zone.today.year + 1})"
    end
  end
end
