# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keyword do
  subject(:keyword) { build(:keyword) }

  it "has a label" do
    expect(keyword.label).to be_present
  end

  it "has a url" do
    expect(keyword.uri).to be_present
  end

  context "when select attributes contain leading/trailing whitespace" do
    let(:work_version) { build(:work_version) }
    let(:keyword) do
      create(
        :keyword,
        label: " World Wide Web ",
        uri: " http://www.wikidata.org/entity/Q466 ",
        work_version:
      )
    end

    it "strips label" do
      expect(keyword.label).to eq("World Wide Web")
    end

    it "strips uri" do
      expect(keyword.uri).to eq("http://www.wikidata.org/entity/Q466")
    end
  end
end
