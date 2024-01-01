# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Change collection of a work" do
  let(:user) { create(:user) }
  let(:work_owner) { create(:user) }
  let(:work_version) { create(:work_version, work:) }
  let(:collection) { create(:collection, druid: "druid:#{druid}") }
  let(:collection_version) { create(:collection_version, collection:) }
  let(:druid) { "qb241yv3557" }
  let(:work) { create(:work, :with_doi, collection:, owner: work_owner) }

  before do
    sign_in user, groups: ["dlss:hydrus-app-administrators"]
    work.update!(head: work_version)
    collection.update!(head: collection_version)
  end

  describe "GET /works/:id/move/edit" do
    it "renders the form" do
      get edit_move_path(work)

      expect(response.body).to include "Enter the druid for a collection"
    end
  end

  describe "GET /works/:id/move/search" do
    context "when a collection is found" do
      it "returns an array with the collection" do
        get search_move_path(work), params: {druid:}

        response_json = response.parsed_body
        expect(response_json).to eq([
          {
            id: collection.id,
            name: "MyString",
            druid: "druid:#{druid}",
            errors: ["Collection is the same as the current collection."]
          }.with_indifferent_access
        ])
      end
    end

    context "when a collection is not found" do
      it "returns an empty array" do
        get search_move_path(work), params: {druid: "druid:abc123"}

        response_json = response.parsed_body
        expect(response_json).to eq([])
      end
    end
  end

  describe "PUT /works/:id/move" do
    let(:new_collection) { create(:collection, :with_druid, :with_depositors, depositor_count: 2) }

    before do
      new_collection.update(head: collection_version)
    end

    it "changes the collection and redirects" do
      put move_path(work), params: {collection: new_collection.id}

      follow_redirect!
      # Flash message
      expect(response.body).to include "Moved"

      expect(work.reload.collection).to eq new_collection
      expect(work.events.last.event_type).to eq "collection_moved"
      expect(new_collection.reload.depositors).to contain_exactly(instance_of(User), instance_of(User), work.owner)
    end

    context "when the work owner is already a depositor in the collection" do
      let(:new_collection) { create(:collection, :with_druid, :with_depositors, depositor_count: 1) }
      let(:work_owner) { new_collection.depositors.first }

      it "changes the collection, redirects, and does not duplicate the work owner as a depositor" do
        put move_path(work), params: {collection: new_collection.id}

        expect(new_collection.reload.depositors).to contain_exactly(work.owner)
      end
    end

    context "when the collection cannot be changed" do
      let(:new_collection) { create(:collection) }

      it "does not change the collection and redirects" do
        put move_path(work), params: {collection: new_collection.id}

        follow_redirect!
        # Flash message
        expect(response.body).to include "Unable to move the work"

        expect(work.reload.collection).to eq collection
      end
    end
  end
end
