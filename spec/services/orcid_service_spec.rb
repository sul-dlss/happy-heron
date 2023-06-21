# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrcidService do
  include Dry::Monads[:result]

  let(:response) { described_class.lookup(orcid:) }

  # rubocop:disable Layout/LineLength
  let(:body) { '{"last-modified-date":{"value":1460763728406},"name":{"created-date":{"value":1460763728406},"last-modified-date":{"value":1460763728406},"given-names":{"value":"Justin"},"family-name":{"value":"Littman"},"credit-name":null,"source":null,"visibility":"public","path":"0000-0003-1527-0030"},"other-names":{"last-modified-date":null,"other-name":[],"path":"/0000-0003-1527-0030/other-names"},"biography":null,"path":"/0000-0003-1527-0030/personal-details"}' }
  # rubocop:enable Layout/LineLength

  context "when bad orcid id" do
    let(:orcid) { "abcd-efgh-ijkl-mnop" }

    it "returns failure with 400" do
      expect(response).to eq(Failure(400))
    end
  end

  context "when an orcid id" do
    let(:orcid) { "0000-0003-1527-0030" }

    before do
      stub_request(:get, "https://pub.orcid.org/v3.0/0000-0003-1527-0030/personal-details")
        .with(
          headers: {
            "Accept" => "application/json",
            "User-Agent" => "Stanford Self-Deposit (Happy Heron)"
          }
        )
        .to_return(status: 200, body:, headers: {})
    end

    it "returns success with first and last name" do
      expect(response).to eq(Success(%w[Justin Littman]))
    end
  end

  context "when an orcid id that requires cleaning" do
    let(:orcid) { "https://orcid.org/0000-0003-1527-003x" }

    before do
      stub_request(:get, "https://pub.orcid.org/v3.0/0000-0003-1527-003X/personal-details")
        .to_return(status: 200, body:, headers: {})
    end

    it "returns success with first and last name" do
      expect(response).to eq(Success(%w[Justin Littman]))
    end
  end

  context "when ORCID API returns an error" do
    let(:orcid) { "https://orcid.org/0000-0003-1527-0030" }

    before do
      stub_request(:get, "https://pub.orcid.org/v3.0/0000-0003-1527-0030/personal-details")
        .to_return(status: 404, body: "", headers: {})
    end

    it "returns failure with status" do
      expect(response).to eq(Failure(404))
    end
  end
end
