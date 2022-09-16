# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  subject(:work) { build(:work, collection:, assign_doi:) }

  let(:assign_doi) { false }

  let(:collection) { build(:collection, doi_option: collection_doi_option) }
  let(:collection_doi_option) { 'yes' }

  it 'belongs to a collection' do
    expect(work.collection).to be_a(Collection)
  end

  describe '#purl' do
    context 'with a druid' do
      before do
        work.druid = 'druid:hb093rg5848'
      end

      it 'constructs purl' do
        expect(work.purl).to eq 'https://purl.stanford.edu/hb093rg5848'
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(work.purl).to be_nil
      end
    end
  end

  describe '#druid_without_namespace' do
    subject { work.druid_without_namespace }

    context 'with a druid' do
      before do
        work.druid = 'druid:hb093rg5848'
      end

      it { is_expected.to eq 'hb093rg5848' }
    end

    context 'with no druid' do
      it { is_expected.to be_nil }
    end
  end
end
