# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Link to edit a collection version" do
  before do
    sign_in user
  end

  let(:collection_version) do
    create(:collection_version_with_collection, :version_draft, collection:)
  end

  let(:rendered) do
    Capybara::Node::Simple.new(response.body)
  end
  let(:user) { create(:user) }

  context "with a user who may edit the object" do
    let(:collection) { create(:collection, managed_by: [user]) }

    it "draws a link" do
      get "/collection_versions/#{collection_version.id}/edit_link"
      expect(response).to have_http_status(:ok)
      expect(rendered).to have_selector("turbo-frame a span.fa-pencil-alt")
    end
  end

  context "with a user who may not edit the object" do
    let(:collection) { create(:collection, depositors: [user]) }

    it "only draws the turbo-frame" do
      get "/collection_versions/#{collection_version.id}/edit_link"
      expect(response).to have_http_status(:ok)
      expect(rendered).to have_selector("turbo-frame")
      expect(rendered).not_to have_link
    end
  end
end
