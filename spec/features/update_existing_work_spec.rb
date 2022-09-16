# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update an existing work in a deposited collection', js: true do
  let(:user) { create(:user) }
  let(:collection_version) { create(:collection_version, :deposited, collection:) }
  let(:collection) { create(:collection, :depositor_selects_access, creator: user, depositors: [user]) }
  let(:work_version) { create(:work_version_with_work, collection:, owner: user, title: original_title) }
  let(:original_title) { 'Not an interesting title' }
  let(:new_title) { 'A much better title' }

  before do
    collection.update(head: collection_version)
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  it 'updates the work and adds to the event description history' do
    visit work_path(work_version.work)

    within '#events' do
      # nothing in the history of events yet
      expect(page).not_to have_content 'title of deposit modified, abstract modified'
    end

    click_link "Edit #{original_title}"

    # breadcrumbs showing
    within '#breadcrumbs' do
      expect(page).to have_content('Dashboard')
      expect(page).to have_content(collection_version.name)
      expect(page).to have_content(original_title)
    end

    # update the title and abstract
    fill_in 'Title of deposit', with: new_title
    fill_in 'Abstract', with: 'I did really cool stuff'

    click_button 'Save as draft'

    # work detail page has new title
    expect(page).to have_content(new_title)
    expect(page).not_to have_content(original_title)
    expect(page).to have_link(collection_version.name)

    within '#events' do
      # The things that have been updated should only be logged in one event
      expect(page).to have_content 'title of deposit modified, abstract modified', count: 1
    end
  end
end
