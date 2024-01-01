# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Update an existing collection", js: true do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, managed_by: [user]) }
  let(:collection_version) { create(:collection_version, :deposited, collection:, name: original_name) }
  let(:original_name) { "Not an interesting name" }
  let(:new_name) { "A much better name" }
  let(:new_version_description) { "Editing the name and description" }

  before do
    collection.update!(head: collection_version)
    sign_in user, groups: ["dlss:hydrus-app-collection-creators"]
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  it "updates the collection and adds to the event description history" do
    visit collection_version_path(collection_version)
    click_link "Collection settings"

    within "#events" do
      # nothing in the history of events yet
      expect(page).not_to have_content "collection name modified, description modified"
    end

    click_link "Collection details"
    click_link "Edit details"

    # breadcrumbs showing
    within "#breadcrumbs" do
      expect(page).to have_content("Dashboard")
      expect(page).to have_content(original_name)
    end

    # update the version description, name, and collection description
    fill_in "What's changing?", with: new_version_description
    fill_in "Collection name", with: new_name
    fill_in "Description", with: "This collection is for interesting stuff"

    click_button "Save as draft"

    # Collection detail page has new name and version description
    expect(page).to have_content(new_name)
    expect(page).not_to have_content(original_name)
    expect(page).to have_content(new_version_description)

    click_link "Collection settings"

    within "#events" do
      # The things that have been updated should only be logged in one event
      expect(page).to have_content "collection name modified, description modified", count: 1
      expect(page).not_to have_content "contact email modified"
      expect(page).not_to have_content "related links modified"
    end

    # Update the contact email only
    click_link "Collection details"
    click_link "Edit details"
    fill_in "What's changing?", with: "Changing the email"
    fill_in "Contact email", with: "user1@stanford.edu"

    click_button "Save as draft"
    click_link "Collection settings"

    within "#events" do
      # The updated email is logged and only in one event
      expect(page).to have_content "contact email modified", count: 1
      expect(page).not_to have_content "related links modified"
    end
  end
end
