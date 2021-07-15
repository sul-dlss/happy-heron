# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Work do
  subject(:work) { build(:work, collection: collection, assign_doi: assign_doi) }

  let(:assign_doi) { false }

  let(:collection) { build(:collection, doi_option: collection_doi_option) }
  let(:collection_doi_option) { 'yes' }

  it 'belongs to a collection' do
    expect(work.collection).to be_a(Collection)
  end

  describe '#purl' do
    context 'with a druid' do
      it 'constructs purl' do
        work.update(druid: 'druid:hb093rg5848')
        expect(work.purl).to eq('http://purl.stanford.edu/hb093rg5848')
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(work.purl).to eq(nil)
      end
    end
  end

  describe '#assign_doi?' do
    context 'when collection specifies DOI is assigned' do
      it 'returns true' do
        expect(work.assign_doi?).to be true
      end
    end

    context 'when collection specifies DOI is not assigned' do
      let(:collection_doi_option) { 'no' }
      let(:assign_doi) { true }

      it 'returns false' do
        expect(work.assign_doi?).to be false
      end
    end

    context 'when collection specifies depositor selects' do
      let(:collection_doi_option) { 'depositor-selects' }

      it 'returns assign_doi' do
        expect(work.assign_doi?).to be false
      end
    end
  end
end
