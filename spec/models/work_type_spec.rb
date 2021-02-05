# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkType do
  describe '.subtypes_for' do
    let(:subtypes) { described_class::IMAGE_TYPES }
    # This value is arbitrary
    let(:type) { 'image' }

    context 'with more types arg' do
      it 'includes the extra types' do
        expect(
          described_class.subtypes_for(type, include_more_types: true)
        ).to eq(subtypes + described_class.more_types)
      end
    end

    context 'without more types arg' do
      it 'defaults to excluding the extra types' do
        expect(
          described_class.subtypes_for(type)
        ).to eq(subtypes)
      end
    end
  end

  describe '.to_h' do
    let(:work_types_hash) { described_class.to_h }

    it 'uses work types as hash keys' do
      expect(work_types_hash.keys).to match_array(described_class.type_list)
    end

    it 'contains all subtypes as values' do
      expect(work_types_hash.values).to match_array(described_class.all.map(&:subtypes))
    end
  end

  describe '.to_json' do
    let(:work_types_json) { described_class.to_json }

    it 'generates valid JSON' do
      expect { JSON.parse(work_types_json) }.not_to raise_error
    end
  end
end
