# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Automatically generate a citation', js: true do
  let(:user) { create(:user) }
  let!(:collection) { create(:collection, :deposited, release_option: 'depositor-selects', depositors: [user]) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when year varies in automatic citation' do
    it 'default, publication, and embargo year in citation' do
      visit dashboard_path

      expect(page).to have_content collection.name

      click_button '+ Deposit to this collection'

      find('label', text: 'Image').click

      click_button 'Continue'

      expect(page).to have_content 'Deposit your content'

      within_section 'Authors to include in citation' do
        fill_in 'First name', with: 'Diana'
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

      # Change the publication year
      fill_in 'Publication year', with: 1996
      blur_from 'Publication year'

      # Citation now has publication year
      expect(elem.value).to have_content 'Scully, D. (1996)'
    end
  end
end
