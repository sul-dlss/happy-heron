# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessGenerator do
  let(:model) { described_class.generate(work: work) }

  context 'when access is world' do
    let(:work) { build(:work) }

    it 'generates the model' do
      expect(model).to eq(access: 'world', download: 'world')
    end
  end

  context 'when access is stanford' do
    let(:work) { build(:work, access: 'stanford') }

    it 'generates the model' do
      expect(model).to eq(access: 'stanford', download: 'stanford')
    end
  end

  context 'when embargoed' do
    let(:work) { build(:work, :embargoed, access: 'stanford') }

    it 'generates the model' do
      expect(model).to eq(access: 'citation-only', download: 'none',
                          embargo: { releaseDate: work.embargo_date.to_s, access: 'world' })
    end
  end
end
