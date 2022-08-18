# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::Generator do
  subject(:model) { described_class.generate(work_version: work_version).to_h }

  let(:contributor) { build(:org_contributor) }
  let(:work_version) do
    build(:work_version, :with_work, :with_creation_date_range, :published, :with_keywords,
          :with_some_untitled_related_links, :with_related_works,
          :with_contact_emails,
          contributors: [contributor],
          citation: "Test citation #{WorkVersion::LINK_TEXT}",
          title: 'Test title')
  end

  let(:citation_value) do
    'Giarlo, M.J. (2013). Academic Libraries as Data Quality Hubs. ' \
      'Journal of Librarianship and Scholarly Communication, 1(3).'
  end
  let(:types_form) do
    [
      {
        source: {
          value: 'Stanford self-deposit resource types'
        },
        structuredValue: [
          {
            type: 'type',
            value: 'Text'
          },
          {
            type: 'subtype',
            value: 'Code'
          },
          {
            type: 'subtype',
            value: 'Oral history'
          }
        ],
        type: 'resource type'
      },
      {
        source: {
          code: 'marcgt'
        },
        type: 'genre',
        uri: 'http://id.loc.gov/vocabulary/marcgt/com',
        value: 'computer program'
      },
      {
        type: 'genre',
        value: 'Oral histories',
        uri: 'http://id.loc.gov/authorities/genreForms/gf2011026431',
        source: {
          code: 'lcgft'
        }
      },
      {
        source: {
          value: 'MODS resource types'
        },
        type: 'resource type',
        value: 'text'
      },
      {
        value: 'Text',
        type: 'resource type',
        source: {
          value: 'DataCite resource types'
        }
      }
    ]
  end
  let(:citation_status_note) do
    [
      {
        type: 'citation status',
        value: 'false'
      }
    ]
  end

  let(:fast_source) do
    {
      code: 'fast',
      uri: 'http://id.worldcat.org/fast/'
    }
  end
  let(:keywords) { work_version.keywords }

  it 'creates description cocina model' do
    expect(model).to eq(
      Cocina::Models::RequestDescription.new(
        event: [
          {
            type: 'deposit',
            date: [
              {
                type: 'publication',
                value: '2019-01-01',
                encoding: { code: 'edtf' }
              }
            ]
          },
          {
            date: [
              {
                encoding: { code: 'edtf' },
                structuredValue: [
                  { value: '2020-03-04', type: 'start' },
                  { value: '2020-10-31', type: 'end' }
                ],
                type: 'creation'
              }
            ],
            type: 'creation'
          },
          {
            date: [
              {
                encoding: { code: 'edtf' },
                value: '2020-02-14',
                type: 'publication',
                status: 'primary'
              }
            ],
            type: 'publication'
          }
        ],
        subject: [
          { type: 'place', value: keywords[0].label, uri: keywords[0].uri, source: fast_source },
          { type: 'place', value: keywords[1].label, uri: keywords[1].uri, source: fast_source },
          { type: 'place', value: keywords[2].label, uri: keywords[2].uri, source: fast_source }
        ],
        note: [
          { type: 'abstract', value: 'test abstract' },
          { type: 'preferred citation', value: 'Test citation :link:' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          {
            name: [{ value: contributor.full_name }],
            type: contributor.contributor_type,
            status: 'primary',
            role: [
              {
                value: 'sponsor',
                code: 'spn',
                uri: 'http://id.loc.gov/vocabulary/relators/spn',
                source: {
                  code: 'marcrelator',
                  uri: 'http://id.loc.gov/vocabulary/relators/'
                }
              }
            ],
            note: citation_status_note
          }
        ],
        relatedResource: [
          {
            title: [{ value: 'My Awesome Research' }],
            access: { url: [{ value: 'http://my.awesome.research.io' }] }
          },
          {
            title: [{ value: 'My Awesome Research' }],
            access: { url: [{ value: 'http://my.awesome.research.io' }] }
          },
          {
            access: { url: [{ value: 'https://your.awesome.research.ai' }] }
          },
          {
            access: { url: [{ value: 'https://your.awesome.research.ai' }] }
          },
          {
            note: [{ value: citation_value, type: 'preferred citation' }]
          },
          {
            note: [{ value: citation_value, type: 'preferred citation' }]
          }
        ],
        form: types_form,
        access: {
          accessContact: [
            {
              value: 'io@io.io',
              type: 'email',
              displayLabel: 'Contact'
            }
          ]
        },
        adminMetadata: {
          event: [
            {
              type: 'creation',
              date: [
                {
                  value: '2019-01-01',
                  encoding: {
                    code: 'edtf'
                  }
                }
              ]
            }
          ],
          note: [
            {
              value: 'Metadata created by user via Stanford self-deposit application',
              type: 'record origin'
            }
          ]
        }
      ).to_h
    )
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   examples 5 and 6
  context 'when contributor of type conference or event' do
    let(:contributor1) { build(:org_contributor, role: 'Event') }
    let(:contributor2) { build(:person_contributor, role: 'Author') }
    let(:contributor3) { build(:org_contributor, role: 'Conference') }
    let(:work_version) do
      build(:work_version, :with_work, :with_contact_emails,
            contributors: [contributor1, contributor2, contributor3],
            title: 'Test title')
    end

    it 'creates forms' do
      expect(model[:form]).to eq(normalize_descriptive_values(types_form))
    end

    it 'creates contributors' do
      expect(model[:contributor]).to eq(normalize_contributors([
                                                                 {
                                                                   name: [{ value: contributor1.full_name }],
                                                                   type: 'event',
                                                                   status: 'primary',
                                                                   role: [
                                                                     {
                                                                       value: 'event'
                                                                     }
                                                                   ],
                                                                   note: citation_status_note
                                                                 },
                                                                 {
                                                                   name: [
                                                                     {
                                                                       structuredValue: [
                                                                         {
                                                                           value: contributor2.first_name,
                                                                           type: 'forename'
                                                                         },
                                                                         {
                                                                           value: contributor2.last_name,
                                                                           type: 'surname'
                                                                         }
                                                                       ]
                                                                     }
                                                                   ],
                                                                   type: 'person',
                                                                   role: [
                                                                     {
                                                                       value: 'author',
                                                                       code: 'aut',
                                                                       uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                                       source: {
                                                                         code: 'marcrelator',
                                                                         uri: 'http://id.loc.gov/vocabulary/relators/'
                                                                       }
                                                                     }
                                                                   ],
                                                                   note: citation_status_note
                                                                 },
                                                                 {
                                                                   name: [{ value: contributor3.full_name }],
                                                                   type: 'conference',
                                                                   role: [
                                                                     {
                                                                       value: 'conference'
                                                                     }
                                                                   ],
                                                                   note: citation_status_note
                                                                 }
                                                               ]))
    end
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   example 13
  #   Note:  no top level contributor -- publisher is under event
  context 'when publisher entered by user, no publication date' do
    let(:contributor) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :with_work, :with_contact_emails,
            contributors: [contributor], title: 'Test title')
    end

    it 'creates no top level contributor' do
      expect(model[:contributor]).to be_empty
    end
  end

  context 'with blank abstract and citation' do
    let(:work_version) do
      build(:work_version, :with_work, abstract: '', citation: '')
    end

    it 'does not add to model' do
      expect(model[:note]).to eq([])
    end
  end

  context 'with subject that has a blank URI and no cocina type' do
    let(:keyword) { build(:keyword, uri: '', cocina_type: '') }

    let(:work_version) do
      build(:work_version, :with_work, keywords: [keyword])
    end

    it 'does not add URI to model' do
      expect(model[:subject]).to eq(normalize_descriptive_values([{ value: keyword.label, type: 'topic' }]))
    end
  end

  context 'when work version does not have published_at' do
    let(:work_version) do
      build(:work_version, :with_work, published_at: nil)
    end

    it 'uses work created_at for adminMetadata creation event' do
      expect(model[:adminMetadata][:event]).to eq(
        [
          Cocina::Models::Event.new(type: 'creation',
                                    date: [
                                      {
                                        value: '2007-02-10',
                                        encoding: { code: 'edtf' }
                                      }
                                    ]).to_h
        ]
      )
    end
  end
end

def normalize_descriptive_values(descriptive_values)
  descriptive_values.map { |descriptive_value| Cocina::Models::DescriptiveValue.new(descriptive_value).to_h }
end

def normalize_contributors(contributors)
  contributors.map { |contributor| Cocina::Models::Contributor.new(contributor).to_h }
end
