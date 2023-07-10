# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accessibility:" do
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:work) { create(:work, collection: collection_version.collection) }
  let(:work_version) { create(:work_version, work:) }
  let(:user) { create(:user) }

  before do
    # Make sure `head` references are set
    work.update(head: work_version)
    collection_version.collection.update(head: collection_version)

    # Default to admin user so pages can load for a11y testing
    sign_in user, groups: ["dlss:hydrus-app-administrators"]
  end

  describe "aXe", driver: :selenium_chrome_headless do
    context "with an unauthorized user" do
      before { sign_in user, groups: [] }

      it "audits the first-time welcome page" do
        visit root_path
        expect(page).to be_accessible
      end
    end

    it "audits the welcome page" do
      visit root_path
      expect(page).to be_accessible
    end

    it "audits the dashboard" do
      visit dashboard_path
      expect(page).to be_accessible
    end

    it "audits the work show page" do
      visit work_path(work_version.work)
      expect(page).to be_accessible
    end

    it "audits the work edit page" do
      skip "TODO: https://github.com/sul-dlss/happy-heron/issues/3224"
      visit edit_work_path(work_version.work)
      expect(page).to be_accessible
    end

    it "audits the collection show page" do
      visit collection_path(collection_version.collection)
      expect(page).to be_accessible
    end

    it "audits the collection edit page" do
      skip "TODO: https://github.com/sul-dlss/happy-heron/issues/3225"
      visit edit_collection_path(collection_version.collection)
      expect(page).to be_accessible
    end

    it "audits the collection works page" do
      visit collection_works_path(collection_version.collection)
      expect(page).to be_accessible
    end

    it "audits the collection version show page" do
      visit collection_version_path(collection_version)
      expect(page).to be_accessible
    end

    it "audits the collection version edit page" do
      skip "TODO: https://github.com/sul-dlss/happy-heron/issues/3226"
      visit edit_collection_version_path(collection_version)
      expect(page).to be_accessible
    end

    it "audits an error page" do
      visit "/foobar"
      expect(page).to be_accessible
    end
  end

  describe "HTML validator" do
    context "with an unauthorized user" do
      before { sign_in user, groups: [] }

      it "validates the first-time welcome page" do
        visit root_path
        expect(page.body).to be_valid_html
      end
    end

    it "validates the welcome page" do
      visit root_path
      expect(page.body).to be_valid_html
    end

    it "validates the dashboard" do
      visit dashboard_path
      expect(page.body).to be_valid_html
    end

    it "validates the work show page" do
      visit work_path(work)
      expect(page.body).to be_valid_html
    end

    it "validates the work edit page" do
      visit edit_work_path(work)
      expect(page.body).to be_valid_html
    end

    it "validates the collection show page" do
      visit collection_path(collection_version.collection)
      expect(page.body).to be_valid_html
    end

    it "validates the collection edit page" do
      visit edit_collection_path(collection_version.collection)
      expect(page.body).to be_valid_html
    end

    it "validates the collection works page" do
      visit collection_works_path(collection_version.collection)
      expect(page.body).to be_valid_html
    end

    it "validates the collection version show page" do
      visit collection_version_path(collection_version)
      expect(page.body).to be_valid_html
    end

    it "validates the collection version edit page" do
      visit edit_collection_version_path(collection_version)
      expect(page.body).to be_valid_html
    end

    it "validates an error page" do
      visit "/foobar"
      expect(page.body).to be_valid_html
    end
  end
end
