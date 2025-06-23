# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrcidStanfordUserService do
  # Contributor with stanford affiliation and orcid, not found in MAIS
  let(:contributor) do
    create(:person_author, orcid: 'https://sandbox.orcid.org/0000-0003-3437-349X')
  end
  let(:client) { instance_double(MaisOrcidClient) }

  before do
    allow(MaisOrcidClient).to receive(:configure).and_return(client)

    # For contributor with stanford affiliation and orcid, not found in MAIS
    create(:affiliation, label: 'stanford university', abstract_contributor: contributor)
    allow(client).to receive(:fetch_orcid_user).with(orcidid: 'https://sandbox.orcid.org/0000-0003-3437-349X').and_return(nil)

    # Contributor with stanford affiliation and orcid, found in MAIS
    contributor1 = create(:person_author, orcid: 'https://sandbox.orcid.org/0000-0003-3437-1234')
    create(:affiliation, label: 'Stanford University', abstract_contributor: contributor1)
    allow(client).to receive(:fetch_orcid_user)
      .with(orcidid: 'https://sandbox.orcid.org/0000-0003-3437-1234')
      .and_return(instance_double(MaisOrcidClient::OrcidUser))

    # Contributor with stanford affiliation, no orcid
    contributor2 = create(:person_author)
    create(:affiliation, label: 'Stanford University', abstract_contributor: contributor2)

    # Contributor with orcid, no stanford affiliation
    create(:person_author, orcid: 'https://sandbox.orcid.org/0000-0003-3437-5678')
  end

  it 'returns contributors with stanford affiliation and orcid but not found in MAIS' do
    expect(described_class.execute).to eq([contributor])
  end
end
