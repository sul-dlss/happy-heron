# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft collection', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
  end

  it 'removes duplicate depositors' do
    visit dashboard_path

    click_link '+ Create a new collection'

    fill_in 'Collection name', with: 'May in California'
    fill_in 'Description', with: 'Objects related to California in May'
    fill_in 'Contact email', with: 'test@example.edu'

    select 'Apache-2.0', from: 'collection_required_license'

    # Adds duplicated users
    fill_in 'Depositors', with: 'user1, user3, user1'

    click_button 'Save as draft'

    # We should not see the user1 duplicate
    expect(page).not_to have_content('user1, user3, user1')
    expect(page).to have_content('user1, user3')
  end
end
