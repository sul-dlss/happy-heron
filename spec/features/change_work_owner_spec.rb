# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Change owner of a work', js: true do
  let(:user) { create(:user) }
  let(:orig_owner) { create(:user) }
  let(:work_version) { create(:work_version, work: work) }
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:work) { create(:work, owner: orig_owner, collection: collection_version.collection) }

  before do
    work.update(head: work_version)
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  it 'allows owner to be changed' do
    visit work_path(work)

    select 'Change owner', from: 'Admin functions'
    expect(page).to have_content 'Enter a valid SUNet ID'
    fill_in 'Enter a valid SUNet ID to change to a new owner', with: 'jcoyne'
    expect(page).to have_content 'No search results found'
    fill_in 'Enter a valid SUNet ID to change to a new owner', with: 'jcoyne85'
    expect(page).to have_content 'Coyne, Justin Michael'
    click_button 'Change owner'

    # Flash message
    expect(page).to have_content 'Owner updated'
    # Event added
    expect(page).to have_content "from #{orig_owner.sunetid} to jcoyne85"
  end
end
