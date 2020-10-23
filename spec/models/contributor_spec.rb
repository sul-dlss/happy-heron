# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor do
  subject(:contributor) { build(:contributor) }

  it 'has a first name' do
    expect(contributor.first_name).to be_present
  end

  it 'has a last name' do
    expect(contributor.last_name).to be_present
  end

  it 'belongs to a work' do
    expect(contributor.work).to be_a(Work)
  end

  describe '.grouped_options' do
    subject(:grouped_options) { described_class.grouped_options }

    it 'makes groups with headings' do
      expect(grouped_options).to eq [['Individual',
                                      [['Advisor', 'person|Advisor'],
                                       ['Author', 'person|Author'],
                                       ['Collector', 'person|Collector'],
                                       ['Contributing author', 'person|Contributing author'],
                                       ['Creator', 'person|Creator'],
                                       ['Editor', 'person|Editor'],
                                       ['Primary advisor', 'person|Primary advisor'],
                                       ['Principal investigator', 'person|Principal investigator']]],
                                     ['Organization',
                                      [['Author', 'organization|Author'],
                                       ['Contributing author', 'organization|Contributing author'],
                                       ['Degree granting institution', 'organization|Degree granting institution'],
                                       ['Distributor', 'organization|Distributor'],
                                       ['Publisher', 'organization|Publisher'],
                                       ['Sponsor', 'organization|Sponsor']]],
                                     ['Conference', [['Conference', 'conference|Conference']]]]
    end
  end

  describe '#role_term=' do
    it 'assigns both role and contributor_type' do
      contributor.role_term = 'organization|Contributing author'
      expect(contributor.contributor_type).to eq 'organization'
      expect(contributor.role).to eq 'Contributing author'
    end
  end

  describe '#role_term' do
    it 'reads both role and contributor_type' do
      expect(contributor.role_term).to eq 'person|Contributing author'
    end
  end
end
