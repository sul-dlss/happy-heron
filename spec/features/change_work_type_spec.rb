# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Change work type", js: true do
  let(:user) { create(:user) }
  let(:orig_owner) { create(:user) }
  let(:work_version) { create(:work_version, work:, state:) }
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:work) { create(:work, owner: orig_owner, collection: collection_version.collection) }

  before do
    work.update(head: work_version)
    sign_in user, groups: ["dlss:hydrus-app-administrators"]
  end

  context "when the work is not in a state that allows changing the work type" do
    let(:state) { :pending_approval }

    it "does not allow work type to be changed" do
      visit work_path(work)

      expect(page).to have_select "Admin functions"
      expect(page).not_to have_select "Admin functions", with_options: ["Change work type"]
    end
  end

  context "when the work is in a state that allows changing the work type" do
    let(:state) { :deposited }

    it "allows work type to be changed" do
      visit work_path(work)

      select "Change work type", from: "Admin functions"

      expect(page).to have_content "What type of content will you deposit?"

      find("label", text: "Sound").click

      find("label", text: "Podcast").click

      click_button "Continue"

      # Flash message
      within ".alert" do
        expect(page).to have_content "New draft created with changed work type / subtypes"
      end

      # Edit page
      expect(page).to have_content "What's changing?"

      new_work_version = work.reload.head
      expect(new_work_version.version).to eq 2
      expect(new_work_version.title).to eq work_version.title
      expect(new_work_version.work_type).to eq "sound"
      expect(new_work_version.subtype).to eq ["Podcast"]
      expect(new_work_version.state).to eq "version_draft"
      expect(new_work_version.version_description).to eq "work type changed"
      expect(work.events.last.description).to eq "work type modified, subtypes modified"
    end
  end
end
