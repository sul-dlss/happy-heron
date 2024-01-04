# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::AffiliationsGenerator do
  subject(:cocina_model) { described_class.generate(contributor:) }

  let(:contributor) { build(:person_contributor, affiliations:) }

  let(:cocina_props) { cocina_model.map(&:to_h) }

  context 'with affiliation with label' do
    let(:affiliations) { [build(:affiliation, label: 'Stanford University')] }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 value: 'Stanford University'
                                               }).to_h

        ]
      )
    end
  end

  context 'with affiliation with label and ROR' do
    let(:affiliations) { [build(:affiliation, label: 'Stanford University', uri: 'https://ror.org/00f54p054')] }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 value: 'Stanford University',
                                                 identifier: [
                                                   {
                                                     uri: 'https://ror.org/00f54p054',
                                                     type: 'ROR',
                                                     source: {
                                                       code: 'ror'
                                                     }
                                                   }
                                                 ]
                                               }).to_h

        ]
      )
    end
  end

  context 'with affiliation with label and department' do
    let(:affiliations) { [build(:affiliation, label: 'Stanford University', department: 'Stanford Libraries')] }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 structuredValue: [
                                                   {
                                                     value: 'Stanford University'
                                                   },
                                                   {
                                                     value: 'Stanford Libraries'
                                                   }
                                                 ]
                                               }).to_h

        ]
      )
    end
  end

  context 'with affiliation with label, ROR, and department' do
    let(:affiliations) { [build(:affiliation, label: 'Stanford University', uri: 'https://ror.org/00f54p054', department: 'Stanford Libraries')] }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 structuredValue: [
                                                   {
                                                     value: 'Stanford University',
                                                     identifier: [
                                                       {
                                                         uri: 'https://ror.org/00f54p054',
                                                         type: 'ROR',
                                                         source: {
                                                           code: 'ror'
                                                         }
                                                       }
                                                     ]
                                                   },
                                                   {
                                                     value: 'Stanford Libraries'
                                                   }
                                                 ]
                                               }).to_h

        ]
      )
    end
  end

  context 'with multiple affiliations' do
    let(:affiliations) do
      [
        build(:affiliation, label: 'Stanford University', uri: 'https://ror.org/00f54p054',
                            department: 'Woods Institute for the Environment'),
        build(:affiliation, label: 'Stanford Medicine', uri: 'https://ror.org/03mtd9a03')

      ]
    end

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 structuredValue: [
                                                   {
                                                     value: 'Stanford University',
                                                     identifier: [
                                                       {
                                                         uri: 'https://ror.org/00f54p054',
                                                         type: 'ROR',
                                                         source: {
                                                           code: 'ror'
                                                         }
                                                       }
                                                     ]
                                                   },
                                                   {
                                                     value: 'Woods Institute for the Environment'
                                                   }
                                                 ]
                                               }).to_h,
          Cocina::Models::DescriptiveValue.new({
                                                 type: 'affiliation',
                                                 value: 'Stanford Medicine',
                                                 identifier: [
                                                   {
                                                     uri: 'https://ror.org/03mtd9a03',
                                                     type: 'ROR',
                                                     source: {
                                                       code: 'ror'
                                                     }
                                                   }
                                                 ]
                                               }).to_h

        ]
      )
    end
  end
end
