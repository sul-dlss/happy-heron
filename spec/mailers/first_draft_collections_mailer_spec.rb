# frozen_string_literal: true

require "rails_helper"

RSpec.describe FirstDraftCollectionsMailer do
  let(:creator) { build_stubbed(:user, name: "Peter Lorre", email: "psl@example.org") }
  let(:collection) { build_stubbed(:collection, creator:) }
  let(:collection_version) { build_stubbed(:collection_version, collection:) }
  let(:collection_name) { collection_version.name }

  describe "#first_draft_created" do
    let(:mail) do
      described_class.with(collection_version:).first_draft_created
    end

    it "renders the headers" do
      expect(mail.subject).to eq "A new collection has been created"
      expect(mail.to).to eq ["h2-administrators@lists.stanford.edu"]
      expect(mail.from).to eq ["no-reply@sdr.stanford.edu"]
    end

    it "renders the body" do
      expect(mail.body.encoded).to match "Dear Administrator,"
      expect(mail.body.encoded).to match "The following new collection has been created in H2:"
      expect(mail.body.encoded).to match "collections/#{collection_version.collection_id}\">#{collection_name}</a>"
    end

    it "body uses creator.name and email" do
      expect(mail.body.encoded).to match "Created by Peter Lorre psl@example.org"
    end
  end
end
