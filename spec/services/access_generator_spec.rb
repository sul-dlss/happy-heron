# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessGenerator do
  let(:model) { described_class.generate(work_version: work_version) }
  let(:license_uri) { License.find('CC0-1.0').uri }

  context 'when license is none' do
    let(:work_version) { build(:work_version, license: 'none') }

    it 'generates the model' do
      expect(model).to eq(access: 'world',
                          download: 'world',
                          useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context 'when access is world' do
    let(:work_version) { build(:work_version) }

    it 'generates the model' do
      expect(model).to eq(access: 'world',
                          download: 'world',
                          license: license_uri,
                          useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context 'when access is stanford' do
    let(:work_version) { build(:work_version, access: 'stanford') }

    it 'generates the model' do
      expect(model).to eq(access: 'stanford',
                          download: 'stanford',
                          license: license_uri,
                          useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context 'when embargoed' do
    let(:work_version) { build(:work_version, :embargoed, access: 'stanford') }

    it 'generates the model' do
      expect(model).to eq(access: 'citation-only',
                          download: 'none',
                          embargo: { releaseDate: work_version.embargo_date.to_s, access: 'world', download: 'world' },
                          license: license_uri,
                          useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end
end
