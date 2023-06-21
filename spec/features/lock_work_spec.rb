# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lock and unlock a work", js: true do
  let(:user) { create(:user) }
  let(:work_version) { create(:work_version, work:) }
  let(:collection_version) { create(:collection_version_with_collection) }

  before do
    work.update(head: work_version)
    sign_in user, groups: ["dlss:hydrus-app-administrators"]
  end

  context "when unlocked" do
    let(:work) { create(:work, owner: user, collection: collection_version.collection) }

    it "allows work to be locked" do
      visit work_path(work)

      expect(work.locked).to be false
      select "Lock/Unlock", from: "Admin functions"
      expect(page).to have_content "Locking this item will prevent anyone from making changes to this item."
      click_button "Lock"

      # Flash message
      expect(page).to have_content "The work was locked"
      # Event added
      expect(page).to have_content "Work locked"

      # verify the value changed in the database
      work.reload
      expect(work.locked).to be true
    end
  end

  context "when locked" do
    let(:work) { create(:work, owner: user, collection: collection_version.collection, locked: true) }

    it "allows work to be unlocked" do
      visit work_path(work)

      expect(work.locked).to be true
      select "Lock/Unlock", from: "Admin functions"
      expect(page).to have_content "Unlocking this item will allow the depositor to make changes to this item."
      click_button "Unlock"

      # Flash message
      expect(page).to have_content "The work was unlocked"
      # Event added
      expect(page).to have_content "Work unlocked"

      # verify the value changed in the database
      work.reload
      expect(work.locked).to be false
    end
  end
end
