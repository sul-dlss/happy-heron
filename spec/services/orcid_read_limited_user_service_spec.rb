# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrcidReadLimitedUserService do
  let(:client) { instance_double(MaisOrcidClient) }

  let(:orcid_user1) do
    MaisOrcidClient::OrcidUser.new("nataliex", "https://sandbox.orcid.org/0000-0003-3437-349X", ["/read-limited", "/activities/update", "/person/update"],
      "XXXXXXXX-1ac5-4ea7-835d-bc6d61ffb9a8", "2020-01-23T17:06:21.000")
  end

  let(:orcid_user2) do
    MaisOrcidClient::OrcidUser.new("nataliey", "https://sandbox.orcid.org/0000-0003-3437-4560", ["/read-limited"],
      "XXXXXXXX-1ac5-4ea7-835d-bc6d61ffb9a8", "2020-01-23T17:06:21.000")
  end

  before do
    create(:person_author, orcid: "https://sandbox.orcid.org/0000-0003-3437-349X")
    create(:person_author, orcid: "https://sandbox.orcid.org/0000-0003-3437-4560")
    create(:person_author)
    allow(MaisOrcidClient).to receive(:configure).and_return(client)
    allow(client).to receive(:fetch_orcid_user).with(orcidid: "https://sandbox.orcid.org/0000-0003-3437-349X").and_return(orcid_user1)
    allow(client).to receive(:fetch_orcid_user).with(orcidid: "https://sandbox.orcid.org/0000-0003-3437-4560").and_return(orcid_user2)
  end

  it "returns read-limited orcid users" do
    expect(described_class.execute).to eq([orcid_user2])
  end
end
