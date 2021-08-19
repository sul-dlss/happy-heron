# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::TypesGenerator do
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
                value: 'Code'
              ),
              Cocina::Models::DescriptiveValue.new(
                type: 'subtype',
                value: 'Oral history'
              )
            ]
          )
        )
      end

      it 'generates a flat array of genres for the subtypes' do
        expect(generated).to include(
          Cocina::Models::DescriptiveValue.new(
            source: { code: 'marcgt' },
            type: 'genre',
            uri: 'http://id.loc.gov/vocabulary/marcgt/com',
            value: 'computer program'
          ),
          Cocina::Models::DescriptiveValue.new(
            type: 'genre',
            value: 'Oral histories',
            uri: 'http://id.loc.gov/authorities/genreForms/gf2011026431',
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

      it 'generates exactly five descriptive values' do
        expect(generated.count).to eq(5)
        expect(generated).to all(be_a(Cocina::Models::DescriptiveValue))
      end
    end

    context 'with a work of type Image with Animation subtype (top level genre plus subtype derived genre)' do
      let(:work_version) { build(:work_version, work_type: 'image', subtype: ['CAD']) }

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
                  value: 'CAD'
                )
              ],
              source: { value: 'Stanford self-deposit resource types' },
              type: 'resource type'
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'Image',
              source: { value: 'DataCite resource types' }
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'genre',
              value: 'Computer-aided designs',
              uri: 'http://id.loc.gov/vocabulary/graphicMaterials/tgm002405',
              source: { code: 'lctgm' }
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
              value: 'Text',
              source: { value: 'DataCite resource types' }
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

      it 'generates a single structured value and a single resource type' do
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
              type: 'resource type',
              value: 'Sound',
              source: { value: 'DataCite resource types' }
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
            ),
            Cocina::Models::DescriptiveValue.new(
              type: 'resource type',
              value: 'Other',
              source: { value: 'DataCite resource types' }
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
      # these represent subtypes that will get the genre from the parent type
      let(:known_genreless) do
        ['Animation', 'Article', 'Book', 'Book chapter', 'Broadcast', 'Conference session', 'Correspondence',
         'Documentation', 'Event', 'Government document', 'Image', 'Manuscript', 'MIDI', 'Musical transcription',
         'Notated music', 'Other spoken word', 'Policy brief', 'Presentation recording', 'Presentation slides',
         'Questionnaire', 'Report', 'Software', 'Sound recording', 'Speaker notes', 'Technical report', 'Text',
         'Thesis', 'Video recording', 'Video art']
      end

      it 'has one genre for each' do
        expect(all_type_genres).to include(*(WorkType.more_types - known_genreless))
      end

      it 'has one resource type for each' do
        expect(all_type_resource_types).to include(*WorkType.more_types)
      end
    end
  end

  # from https://github.com/sul-dlss/dor-services-app/blob/main/spec/services/cocina/mapping/descriptive/h2/form_h2_spec.rb
  # The contexts below match the spec names from above. The expected cocina props are copied directly.
  describe 'h2 mapping specification examples' do
    subject(:cocina_props) { { form: described_class.generate(work_version: work_version).map(&:to_h) } }

    let(:work_version) { build(:work_version, work_type: work_type, subtype: work_subtypes) }

    context 'with type only, resource type with URI' do
      let(:work_type) { 'data' }
      let(:work_subtypes) { [] }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            form: [
              {
                structuredValue: [
                  {
                    value: 'Data',
                    type: 'type'
                  }
                ],
                source: {
                  value: 'Stanford self-deposit resource types'
                },
                type: 'resource type'
              },
              {
                type: 'resource type',
                value: 'Dataset',
                source: { value: 'DataCite resource types' }
              },
              {
                value: 'Data sets',
                type: 'genre',
                uri: 'http://id.loc.gov/authorities/genreForms/gf2018026119',
                source: {
                  code: 'lcgft'
                }
              },
              {
                value: 'dataset',
                type: 'genre',
                source: {
                  code: 'local'
                }
              },
              {
                value: 'Dataset',
                type: 'resource type',
                uri: 'http://id.loc.gov/vocabulary/resourceTypes/dat',
                source: {
                  uri: 'http://id.loc.gov/vocabulary/resourceTypes/'
                }
              }
            ]
          }
        )
      end
    end

    context 'with type and subtype' do
      let(:work_type) { 'text' }
      let(:work_subtypes) { ['Article'] }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            form: [
              {
                structuredValue: [
                  {
                    value: 'Text',
                    type: 'type'
                  },
                  {
                    value: 'Article',
                    type: 'subtype'
                  }
                ],
                source: {
                  value: 'Stanford self-deposit resource types'
                },
                type: 'resource type'
              },
              {
                type: 'resource type',
                value: 'Text',
                source: { value: 'DataCite resource types' }
              },
              {
                value: 'text',
                type: 'resource type',
                source: {
                  value: 'MODS resource types'
                }
              }
            ]
          }
        )
      end
    end

    context 'with type and multiple subtypes' do
      let(:work_type) { 'software, multimedia' }
      let(:work_subtypes) { %w[Code Documentation] }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            form: [
              {
                structuredValue: [
                  {
                    value: 'Software/Code',
                    type: 'type'
                  },
                  {
                    value: 'Code',
                    type: 'subtype'
                  },
                  {
                    value: 'Documentation',
                    type: 'subtype'
                  }
                ],
                source: {
                  value: 'Stanford self-deposit resource types'
                },
                type: 'resource type'
              },
              {
                type: 'resource type',
                value: 'Software',
                source: { value: 'DataCite resource types' }
              },
              {
                value: 'computer program',
                type: 'genre',
                uri: 'http://id.loc.gov/vocabulary/marcgt/com',
                source: {
                  code: 'marcgt'
                }
              },
              {
                value: 'software, multimedia',
                type: 'resource type',
                source: {
                  value: 'MODS resource types'
                }
              },
              {
                value: 'text',
                type: 'resource type',
                source: {
                  value: 'MODS resource types'
                }
              }
            ]
          }
        )
      end
    end

    context 'with Other - Dance notation (Other type with user-entered subtype)' do
      let(:work_type) { 'other' }
      let(:work_subtypes) { ['Dance notation'] }

      it 'generates cocina props' do
        expect(cocina_props).to eq(
          {
            form: [
              {
                structuredValue: [
                  {
                    value: 'Other',
                    type: 'type'
                  },
                  {
                    value: 'Dance notation',
                    type: 'subtype'
                  }
                ],
                source: {
                  value: 'Stanford self-deposit resource types'
                },
                type: 'resource type'
              },
              {
                type: 'resource type',
                value: 'Other',
                source: { value: 'DataCite resource types' }
              }
            ]
          }
        )
      end
    end
  end
end
