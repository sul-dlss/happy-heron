# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkType do
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
