# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::Generator do
  subject(:model) { described_class.generate(work_version: work_version).to_h }

  let(:contributor) { build(:org_contributor) }
  let(:work_version) do
    build(:work_version, :with_creation_date_range, :published, :with_keywords,
          :with_some_untitled_related_links, :with_related_works,
          :with_contact_emails,
          contributors: [contributor],
          citation: "Test citation #{WorkVersion::LINK_TEXT}",
          title: 'Test title')
  end

  let(:citation_value) do
    'Giarlo, M.J. (2013). Academic Libraries as Data Quality Hubs. '\
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
  let(:marc_relator_source) do
    {
      code: 'marcrelator',
      uri: 'http://id.loc.gov/vocabulary/relators/'
    }
  end
  let(:publisher_roles) do
    [
      {
        value: 'publisher',
        code: 'pbl',
        uri: 'http://id.loc.gov/vocabulary/relators/pbl',
        source: marc_relator_source
      }
    ]
  end
  let(:contributor_role) do
    {
      value: 'contributor',
      code: 'ctb',
      uri: 'http://id.loc.gov/vocabulary/relators/ctb',
      source: {
        code: 'marcrelator',
        uri: 'http://id.loc.gov/vocabulary/relators/'
      }
    }
  end
  let(:author_roles) do
    [
      {
        value: 'author',
        code: 'aut',
        uri: 'http://id.loc.gov/vocabulary/relators/aut',
        source: marc_relator_source
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
  let(:admin_metadata) do
    {
      event: [
        {
          type: 'creation',
          date: [
            {
              value: '2007-02-10',
              encoding: {
                code: 'w3cdtf'
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
  end
  let(:fast_source) do
    {
      code: 'fast',
      uri: 'http://id.worldcat.org/fast/'
    }
  end

  it 'creates description cocina model' do
    expect(model).to eq(
      Cocina::Models::RequestDescription.new(
        event: [
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
                type: 'publication'
              }
            ],
            type: 'publication'
          }
        ],
        subject: [
          { type: 'place', value: 'MyKeyword', uri: 'http://example.org/uri', source: fast_source },
          { type: 'place', value: 'MyKeyword', uri: 'http://example.org/uri', source: fast_source },
          { type: 'place', value: 'MyKeyword', uri: 'http://example.org/uri', source: fast_source }
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
        adminMetadata: admin_metadata
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
      build(:work_version, :with_contact_emails,
            contributors: [contributor1, contributor2, contributor3],
            title: 'Test title')
    end

    it 'creates forms as well as contributors in description cocina model' do
      expect(model).to eq(Cocina::Models::RequestDescription.new(
        note: [
          { type: 'abstract', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
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
            role: author_roles,
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
        adminMetadata: admin_metadata
      ).to_h)
    end
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   example 12
  context 'when publisher and publication date are entered by user' do
    let(:contributor) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :published, :with_contact_emails,
            contributors: [contributor],
            title: 'Test title')
    end

    it 'creates event of type publication with date' do
      expect(model).to eq(Cocina::Models::RequestDescription.new(
        note: [
          { type: 'abstract', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        event: [
          {
            type: 'publication',
            contributor: [
              {
                name: [{ value: contributor.full_name }],
                role: publisher_roles,
                type: 'organization'
              }
            ],
            date: [
              {
                encoding: { code: 'edtf' },
                value: '2020-02-14',
                type: 'publication'
              }
            ]
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
        adminMetadata: admin_metadata
      ).to_h)
    end
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   example 13
  #   Note:  no top level contributor -- publisher is under event
  context 'when publisher entered by user, no publication date' do
    let(:contributor) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :with_contact_emails,
            contributors: [contributor], title: 'Test title')
    end

    it 'creates event of type publication without date' do
      expect(model).to eq(Cocina::Models::RequestDescription.new(
        note: [
          { type: 'abstract', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        event: [
          {
            type: 'publication',
            contributor: [
              {
                name: [{ value: contributor.full_name }],
                role: publisher_roles,
                type: 'organization'
              }
            ]
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
        adminMetadata: admin_metadata
      ).to_h)
    end
  end

  # NOTE: Arcadia to add h2 mapping spec for when there is a person and a publisher
  context 'when author, publisher and publication date are entered by user' do
    let(:person_author) { build(:person_author, role: 'Author') }
    let(:pub_contrib) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :published, :with_contact_emails,
            authors: [person_author],
            contributors: [pub_contrib], title: 'Test title')
    end

    it 'creates event of type publication with date' do
      expect(model).to eq(Cocina::Models::RequestDescription.new(
        note: [
          { type: 'abstract', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          {
            name: [
              {
                structuredValue: [
                  {
                    value: person_author.first_name,
                    type: 'forename'
                  },
                  {
                    value: person_author.last_name,
                    type: 'surname'
                  }
                ]
              }
            ],
            type: person_author.contributor_type,
            status: 'primary',
            role: author_roles
          }
        ],
        event: [
          {
            type: 'publication',
            contributor: [
              {
                name: [{ value: pub_contrib.full_name }],
                role: publisher_roles,
                type: 'organization'
              }
            ],
            date: [
              {
                encoding: { code: 'edtf' },
                value: '2020-02-14',
                type: 'publication'
              }
            ]
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
        adminMetadata: admin_metadata
      ).to_h)
    end

    context 'when publication date of year only' do
      let(:work_version) do
        build(:work_version, :published_with_year_only)
      end

      it 'creates event of type publication with year only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'publication',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2021',
                                            type: 'publication'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when publication date of year and month only' do
      let(:work_version) do
        build(:work_version, :published_with_year_month_only)
      end

      it 'creates event of type publication with year and month only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'publication',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2021-04',
                                            type: 'publication'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when creation date of year only' do
      let(:work_version) do
        build(:work_version, :with_creation_date_year_only)
      end

      it 'creates event of type creation with year only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2020',
                                            type: 'creation'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when creation date of year and month only' do
      let(:work_version) do
        build(:work_version, :with_creation_date_year_month_only)
      end

      it 'creates event of type creation with year and month only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2020-06',
                                            type: 'creation'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when approximate creation date' do
      let(:work_version) do
        build(:work_version, :with_approximate_creation_date)
      end

      it 'creates event of type creation with approximate date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2020-03-08',
                                            type: 'creation',
                                            qualifier: 'approximate'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when approximate creation date of year only' do
      let(:work_version) do
        build(:work_version, :with_approximate_creation_date_year_only)
      end

      it 'creates event of type creation with approximate year only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2020',
                                            type: 'creation',
                                            qualifier: 'approximate'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when approximate creation date of year and month only date' do
      let(:work_version) do
        build(:work_version, :with_approximate_creation_date_year_month_only)
      end

      it 'creates event of type creation with approximate year and month only date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            value: '2020-06',
                                            type: 'creation',
                                            qualifier: 'approximate'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end

    context 'when approximate creation date range' do
      let(:work_version) do
        build(:work_version, :with_approximate_creation_date_range)
      end

      it 'creates event of type creation with approximate date' do
        expect(model[:event]).to eq(
          [
            Cocina::Models::Event.new({
                                        type: 'creation',
                                        date: [
                                          {
                                            encoding: { code: 'edtf' },
                                            structuredValue: [
                                              { value: '2020-03-04', type: 'start' },
                                              { value: '2020-10-31', type: 'end' }
                                            ],
                                            qualifier: 'approximate',
                                            type: 'creation'
                                          }
                                        ]
                                      }).to_h
          ]
        )
      end
    end
  end

  context 'with blank abstract and citation' do
    let(:work_version) do
      build(:work_version, abstract: '', citation: '')
    end

    it 'does not add to model' do
      expect(model[:note]).to eq([])
    end
  end

  context 'with subject that has a blank URI and no cocina type' do
    let(:keyword) { build(:keyword, uri: '', cocina_type: '') }

    let(:work_version) do
      build(:work_version, keywords: [keyword])
    end

    it 'does not add URI to model' do
      expect(model[:subject]).to eq [Cocina::Models::DescriptiveValue.new({ value: 'MyKeyword', type: 'topic' }).to_h]
    end
  end
end
