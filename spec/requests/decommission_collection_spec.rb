# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Decommission a collection" do
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:collection) { collection_version.collection }
  let(:groups) { [] }
  let(:user) { create(:user) }

  before do
    collection.update!(head: collection_version)
    sign_in user, groups:
  end

  describe "GET /collections/:id/decommission/edit" do
    context "with an authorized user" do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }

      it "renders the form" do
        get edit_collection_decommission_path(collection)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("I confirm this collection has been decommissioned in Argo")
      end
    end

    context "with an unauthorized user" do
      it "redirects and renders an error message" do
        get edit_collection_decommission_path(collection)

        follow_redirect!

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You are not authorized to perform the requested action")
      end
    end
  end

  describe "PUT /collections/:id/decommission" do
    context "with an authorized user" do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }

      context "when collection has zero non-decommissioned works" do
        it "redirects to the collection page and confirms it was decommissioned" do
          put collection_decommission_path(collection)

          follow_redirect!

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Decommissioned")
        end
      end

      context "when collection has non-decommissioned works" do
        let!(:work) { create(:work_version_with_work, collection:) } # rubocop:disable RSpec/LetSetup

        it "redirects to the collection page and confirms it was decommissioned" do
          put collection_decommission_path(collection)

          follow_redirect!

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(
            "You must decommission the items in this collection before you can decommission the collection"
          )
        end
      end
    end

    context "with an unauthorized user" do
      it "redirects and renders an error message" do
        put collection_decommission_path(collection)

        follow_redirect!

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You are not authorized to perform the requested action")
      end
    end
  end
end
