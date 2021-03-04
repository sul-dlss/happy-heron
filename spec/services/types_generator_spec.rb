# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TypesGenerator do
  let(:work_version) { build(:work_version) }

  describe '.generate' do
    subject(:generated) { described_class.generate(work_version: work_version) }

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

    context 'with a work of type Image with Image subtype (no subtype derived genre)' do
      let(:work_version) { build(:work_version, work_type: 'image', subtype: ['Image']) }

      it 'generates a single structured value, a single resource type and single genre' do
        expect(generated).to eq(
          [
            Cocina::Models::DescriptiveValue.new(
              structuredValue: [
                Cocina::Models::DescriptiveValue.new(
                  type: 'type',
                  value: 'Image'
                ),
                Cocina::Models::DescriptiveValue.new(
                  type: 'subtype',
                  value: 'Image'
                )
              ],
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type'
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'genre',
              value: 'Pictures',
              uri: 'http://id.loc.gov/authorities/genreForms/gf2017027251',
              source: { code: 'lcgft' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'still image',
              source: { value: 'MODS resource types' }
            )
          ]
        )
      end
    end

    context 'with a work of type Image with Animation subtype (top level genre plus subtype derived genre)' do
      let(:work_version) { build(:work_version, work_type: 'image', subtype: ['Animation']) }

      it 'generates a single structured value, two resource types and two genres' do
        expect(generated).to eq(
          [
            Cocina::Models::DescriptiveValue.new(
              structuredValue: [
                Cocina::Models::DescriptiveValue.new(
                  type: 'type',
                  value: 'Image'
                ),
                Cocina::Models::DescriptiveValue.new(
                  type: 'subtype',
                  value: 'Animation'
                )
              ],
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type'
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'genre',
              value: 'Pictures',
              uri: 'http://id.loc.gov/authorities/genreForms/gf2017027251',
              source: { code: 'lcgft' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'genre',
              value: 'animations (visual works)',
              uri: 'http://vocab.getty.edu/aat/300411663',
              source: { code: 'aat' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'still image',
              source: { value: 'MODS resource types' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'moving image',
              source: { value: 'MODS resource types' }
            )
          ]
        )
      end
    end

    context 'with a work of type Text lacking subtypes' do
      let(:work_version) { build(:work_version, work_type: 'text', subtype: []) }

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
      let(:work_version) { build(:work_version, work_type: 'sound', subtype: []) }

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
      let(:work_version) { build(:work_version, work_type: 'other', subtype: ['Dance notation']) }

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

  describe 'cocina mapping' do
    work_types = WorkType.all

    let(:generator) { described_class.new(work_version: work_version) }
    let(:types_to_genres) { generator.send(:types_to_genres) }
    let(:types_to_resource_types) { generator.send(:types_to_resource_types) }

    describe 'for work types' do
      # NOTE: the Other type has no mappings
      let(:work_type_labels) { work_types.map(&:label) }

      it 'has one genre for each' do
        # NOTE: General mappings do not correspond to a particular type
        expect(work_type_labels).to match_array(types_to_genres.keys - ['General'])
      end

      it 'has one resource type for each' do
        # NOTE: General mappings do not correspond to a particular type
        expect(work_type_labels).to match_array(types_to_resource_types.keys - ['General'])
      end
    end

    describe 'for "more" types' do
      let(:all_type_genres) do
        types_to_genres
          .values
          .map { |work_type| work_type['subtypes'].keys }
          .flatten
          .sort
          .uniq
      end
      let(:all_type_resource_types) do
        types_to_resource_types
          .values
          .map { |work_type| work_type['subtypes'].keys }
          .flatten
          .sort
          .uniq
      end
      let(:known_genreless) { ['Policy brief', 'Speaker notes'] }

      it 'has one genre for each' do
        expect(all_type_genres).to include(*(WorkType.more_types - known_genreless))
      end

      it 'has one resource type for each' do
        expect(all_type_resource_types).to include(*WorkType.more_types)
      end
    end
  end
end
