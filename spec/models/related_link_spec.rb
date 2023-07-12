# frozen_string_literal: true

require "rails_helper"

RSpec.describe RelatedLink do
  subject(:related_link) { build(:related_link, linkable: work) }

  let(:work) { build(:work) }

  it "has a title" do
    expect(related_link.link_title).to be_present
  end

  it "has a url" do
    expect(related_link.url).to be_present
  end

  it "belongs to a work" do
    expect(related_link.linkable).to eq work
  end

  context "when select attributes contain leading/trailing whitespace" do
    let(:related_link) do
      create(
        :related_link,
        link_title: " The RTF file ",
        url: " https://www.w3.org/History/1989/proposal.rtf ",
        linkable: work
      )
    end

    it "strips title" do
      expect(related_link.link_title).to eq("The RTF file")
    end

    it "strips url" do
      expect(related_link.url).to eq("https://www.w3.org/History/1989/proposal.rtf")
    end
  end
end
