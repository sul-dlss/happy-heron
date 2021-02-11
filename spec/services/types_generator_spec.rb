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
    non_other_work_types = WorkType.all.reject { |work_type| work_type.id == 'other' }

    let(:generator) { described_class.new(work_version: work_version) }
    let(:types_to_genres) { generator.send(:types_to_genres) }
    let(:types_to_resource_types) { generator.send(:types_to_resource_types) }

    describe 'for work types' do
      # NOTE: the Other type has no mappings
      let(:work_type_labels) { non_other_work_types.map(&:label) }

      it 'has one genre for each' do
        # NOTE: General mappings do not correspond to a particular type
        expect(work_type_labels).to match_array(types_to_genres.keys - ['General'])
      end

      it 'has one resource type for each' do
        # NOTE: General mappings do not correspond to a particular type
        expect(work_type_labels).to match_array(types_to_resource_types.keys - ['General'])
      end
    end

    describe 'for subtypes' do
      non_other_work_types.each do |work_type|
        context "with type #{work_type.label}" do
          let(:known_genreless) do
            case work_type.label
            when 'Data'
              ['Documentation']
            when 'Text'
              ['Policy brief']
            else
              []
            end
          end

          it 'has a one-to-one genre mapping to subtypes' do
            expect(work_type.subtypes - known_genreless).to eq(types_to_genres[work_type.label]['subtypes'].keys)
          end

          it 'has a one-to-one resource type mapping to subtypes' do
            expect(work_type.subtypes).to eq(types_to_resource_types[work_type.label]['subtypes'].keys)
          end
        end
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
