# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orcid do
  describe "REGEX" do
    it "returns valid" do
      expect(valid?("https://orcid.org/0000-0003-1527-0030")).to be true
      expect(valid?("https://orcid.org/0000-0003-1527-003X")).to be true
      expect(valid?("https://sandbox.orcid.org/0000-0003-1527-003X")).to be true
    end

    it "returns invalid" do
      expect(valid?("https://orcid.org/0000-0003-1527-003Y")).to be false
      expect(valid?("0000-0003-1527-0030")).to be false
    end
  end

  describe "#split" do
    let(:split) { described_class.split(orcid_id) }

    context "with an ORCID" do
      let(:orcid_id) { "https://orcid.org/0000-0003-1527-0030" }

      it "returns split ORCID" do
        expect(split).to eq(["https://orcid.org", "0000-0003-1527-0030"])
      end
    end

    context "with an invalid ORCID" do
      let(:orcid_id) { nil }

      it "returns nil" do
        expect(split).to eq([nil, nil])
      end
    end
  end

  def valid?(orcid_id)
    Orcid::REGEX.match(orcid_id).present?
  end
end
