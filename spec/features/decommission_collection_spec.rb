# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Decommission a collection', :js do
  let(:user) { create(:user) }
  let(:collection_version) { create(:collection_version_with_collection) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  it 'allows collection to be decommissioned' do
    visit collection_path(collection_version.collection)

    select 'Decommission collection', from: 'Admin functions'
    expect(page).to have_content 'I confirm this collection has been decommissioned in Argo'
    check 'confirmCheckbox'
    click_link_or_button 'Decommission collection from H2'

    # Flash message
    within '.alert' do
      expect(page).to have_content 'Decommissioned'
    end

    # State
    expect(find('span.state').text).to eq 'Decommissioned'

    # Event added
    within '#events' do
      expect(page).to have_content 'Decommissioned'
    end
  end
end
