# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Decommission a work', :js do
  let(:user) { create(:user) }
  let(:orig_owner) { create(:user) }
  let(:work_version) { create(:work_version, work:) }
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:work) { create(:work, owner: orig_owner, collection: collection_version.collection) }

  before do
    work.update(head: work_version)
    create(:attached_file, :with_file, work_version:)
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  it 'allows work to be decommissioned' do
    visit work_path(work)

    within '#filesTable' do
      expect(page).to have_content 'sul.svg'
    end

    select 'Decommission', from: 'Admin functions'
    expect(page).to have_content 'I confirm this item has been decommissioned in Argo'
    check 'confirmCheckbox'
    click_link_or_button 'Decommission from H2'

    # Flash message
    within '.alert' do
      expect(page).to have_content 'Decommissioned'
    end

    # State
    expect(find('span.state').text).to eq 'Decommissioned'

    # Owner changed
    expect(page).to have_content 'Owner'
    expect(page).to have_content user.sunetid

    # Event added
    within '#events' do
      expect(page).to have_content 'Decommissioned'
    end

    # Files removed
    within '#filesTable' do
      expect(page).to have_no_content 'sul.svg'
    end
  end
end
