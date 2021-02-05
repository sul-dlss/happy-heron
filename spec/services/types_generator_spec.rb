# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TypesGenerator do
  let(:work) { build(:work) }

  describe '.generate' do
    let(:instance) { instance_double(described_class, generate: []) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'calls #generate on a new instance' do
      described_class.generate(work: work)
      expect(instance).to have_received(:generate).once
    end
  end

  describe '#generate' do
    subject(:generated) { described_class.generate(work: work) }

    context 'with a work containing multiple subtypes' do
      it 'generates a flat array of structured values for the work type and subtypes' do
        expect(generated).to include(
          Cocina::Models::DescriptiveValue.new(
            source: { value: 'Stanford self-deposit resource types' },
            type: 'resource type',
            structuredValue: [
              Cocina::Models::DescriptiveValue.new(
                type: 'type',
                value: 'Text'
              ),
              Cocina::Models::DescriptiveValue.new(
                type: 'subtype',
                value: 'Article'
              ),
              Cocina::Models::DescriptiveValue.new(
                type: 'subtype',
                value: 'Technical report'
              )
            ]
          )
        )
      end

      it 'generates a flat array of genres for the subtypes' do
        expect(generated).to include(
          Cocina::Models::DescriptiveValue.new(
            type: 'genre',
            value: 'articles',
            uri: 'http://vocab.getty.edu/aat/300048715',
            source: { code: 'aat' }
          ),
          Cocina::Models::DescriptiveValue.new(
            type: 'genre',
            value: 'Technical reports',
            uri: 'http://id.loc.gov/authorities/genreForms/gf2015026093',
            source: { code: 'lcgft' }
          )
        )
      end

      it 'generates a flat array of resource types' do
        expect(generated).to include(
          Cocina::Models::DescriptiveValue.new(
            type: 'resource type',
            value: 'text',
            source: { value: 'MODS resource types' }
          )
        )
      end

      it 'generates exactly four descriptive values' do
        expect(generated.count).to eq(4)
        expect(generated).to all(be_a(Cocina::Models::DescriptiveValue))
      end
    end

    context 'with a work of type Text lacking subtypes' do
      let(:work) { build(:work, work_type: 'text', subtype: []) }

      it 'generates a single structured value, a single resource type and no genre' do
        expect(generated).to eq(
          [
            Cocina::Models::DescriptiveValue.new(
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type',
              structuredValue: [
                Cocina::Models::DescriptiveValue.new(
                  type: 'type',
                  value: 'Text'
                )
              ]
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'text',
              source: { value: 'MODS resource types' }
            )
          ]
        )
      end
    end

    context 'with a work of type Sound lacking subtypes' do
      let(:work) { build(:work, work_type: 'sound', subtype: []) }

      it 'generates a single structured value, a single resource type, and a single genre' do
        expect(generated).to eq(
          [
            Cocina::Models::DescriptiveValue.new(
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type',
              structuredValue: [
                Cocina::Models::DescriptiveValue.new(
                  type: 'type',
                  value: 'Sound'
                )
              ]
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'genre',
              value: 'Sound recordings',
              uri: 'http://id.loc.gov/authorities/genreForms/gf2011026594',
              source: { code: 'lcgft' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'sound recording',
              source: { value: 'MODS resource types' }
            )
          ]
        )
      end
    end

    context 'with a work of type "Other"' do
      let(:work) { build(:work, work_type: 'other', subtype: ['Dance notation']) }

      it 'generates only a structured value' do
        expect(generated).to eq(
          [
            Cocina::Models::DescriptiveValue.new(
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type',
              structuredValue: [
                Cocina::Models::DescriptiveValue.new(
                  type: 'type',
                  value: 'Other'
                ),
                Cocina::Models::DescriptiveValue.new(
                  type: 'subtype',
                  value: 'Dance notation'
                )
              ]
            )
          ]
        )
      end
    end
  end
end
