# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { build(:collection, :with_works) }

  it 'has many works' do
    expect(collection.works).to all(be_a(Work))
  end

  describe '#purl' do
    context 'with a druid' do
      it 'constructs purl' do
        collection.update(druid: 'druid:hb093rg5848')
        expect(collection.purl).to eq('http://purl.stanford.edu/hb093rg5848')
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(collection.purl).to eq(nil)
      end
    end
  end

  describe '#user_can_set_license?' do
    subject { collection.user_can_set_license? }

    context 'when the required license is set' do
      let(:collection) { build(:collection, :with_required_license) }

      it { is_expected.to be false }
    end

    context 'when the required license is not set' do
      it { is_expected.to be true }
    end
  end
end
