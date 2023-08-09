# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectionVersionEventDescriptionBuilder do
  subject(:result) { described_class.build(form) }

  let(:collection) { create(:collection) }
  let(:collection_version) { create(:collection_version_with_collection, collection:) }
  let(:form) { DraftCollectionForm.new(collection_version:, collection:) }

  context "when nothing has changed" do
    before do
      form.validate({})
    end

    it { is_expected.to be_blank }
  end

  context "when name has changed" do
    before do
      form.validate(name: "new name")
    end

    it { is_expected.to eq "collection name modified" }
  end

  context "when many fields have changed" do
    before do
      form.validate(
        name: "new name",
        description: "foo",
        contact_emails: [{"email" => "foo@bar.io"}],
        related_links: [{"link_title" => "Hey", "url" => "http://io.io"}]
      )
    end

    it "has a complete description" do
      expect(result).to eq "collection name modified, description modified, " \
                           "contact email modified, related links modified"
    end
  end

  context "when related link added" do
    before do
      form.validate(related_links: [{"_destroy" => "", "link_title" => "Hey", "url" => "http://io.io"}])
    end

    it "has a complete description" do
      expect(result).to eq "related links modified"
    end
  end

  context "when related link changed" do
    let(:related_link) { create(:related_link, linkable: collection_version) }

    before do
      collection_version.related_links << related_link

      form.validate("related_links_attributes" => {"0" => {"_destroy" => "",
                                                           "id" => related_link.id.to_s,
                                                           "link_title" => "changed-#{related_link.link_title}",
                                                           "url" => related_link.url}})
    end

    it "has a complete description" do
      expect(result).to eq "related links modified"
    end
  end

  context "when related link unchanged" do
    let(:related_link) { create(:related_link, linkable: collection_version) }

    before do
      collection_version.related_links << related_link

      form.validate("related_links_attributes" => {"0" => {"_destroy" => "",
                                                           "id" => related_link.id.to_s,
                                                           "link_title" => related_link.link_title.to_s,
                                                           "url" => related_link.url}})
    end

    it "has a complete description" do
      expect(result).to eq ""
    end
  end

  context "when related link removed" do
    let(:related_link) { create(:related_link, linkable: collection_version) }

    before do
      collection_version.related_links << related_link
      # collection_version.save!

      form.validate("related_links_attributes" => {"0" => {"_destroy" => "1",
                                                           "id" => related_link.id.to_s,
                                                           "link_title" => related_link.link_title.to_s,
                                                           "url" => related_link.url}})
    end

    it "has a complete description" do
      expect(result).to eq "related links modified"
    end
  end

  context "when contact email added" do
    before do
      form.validate(contact_emails: [{"_destroy" => "", "email" => "leland@stanford.edu"}])
    end

    it "has a complete description" do
      expect(result).to eq "contact email modified"
    end
  end

  context "when contact email changed" do
    let(:contact_email) { create(:contact_email, emailable: collection_version) }

    before do
      collection_version.contact_emails << contact_email

      form.validate("contact_emails_attributes" => {"0" => {"_destroy" => "", "id" => contact_email.id.to_s,
                                                            "email" => "changed-#{contact_email.email}"}})
    end

    it "has a complete description" do
      expect(result).to eq "contact email modified"
    end
  end

  context "when contact email unchanged" do
    let(:contact_email) { create(:contact_email, emailable: collection_version) }

    before do
      collection_version.contact_emails << contact_email

      form.validate("contact_emails_attributes" => {"0" => {"_destroy" => "", "id" => contact_email.id.to_s,
                                                            "email" => contact_email.email.to_s}})
    end

    it "has a complete description" do
      expect(result).to eq ""
    end
  end

  context "when contact email removed" do
    let(:contact_email) { create(:contact_email, emailable: collection_version) }

    before do
      collection_version.contact_emails << contact_email

      form.validate("contact_emails_attributes" => {"0" => {"_destroy" => "1", "id" => contact_email.id.to_s,
                                                            "email" => contact_email.email.to_s}})
    end

    it "has a complete description" do
      expect(result).to eq "contact email modified"
    end
  end
end
