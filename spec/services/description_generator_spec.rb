# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionGenerator do
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
            value: 'Article'
          },
          {
            type: 'subtype',
            value: 'Technical report'
          }
        ],
        type: 'resource type'
      },
      {
        source: {
          code: 'aat'
        },
        type: 'genre',
        uri: 'http://vocab.getty.edu/aat/300048715',
        value: 'articles'
      },
      {
        type: 'genre',
        value: 'Technical reports',
        uri: 'http://id.loc.gov/authorities/genreForms/gf2015026093',
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
      },
      contributor_role
    ]
  end

  it 'creates description cocina model' do
    expect(model).to eq(
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
        { type: 'topic', value: 'MyString' },
        { type: 'topic', value: 'MyString' },
        { type: 'topic', value: 'MyString' }
      ],
      note: [
        { type: 'summary', value: 'test abstract' },
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
            },
            contributor_role
          ]
        }
      ],
      relatedResource: [
        {
          type: 'related to',
          title: [{ value: 'My Awesome Research' }],
          access: { url: [{ value: 'http://my.awesome.research.io' }] }
        },
        {
          type: 'related to',
          title: [{ value: 'My Awesome Research' }],
          access: { url: [{ value: 'http://my.awesome.research.io' }] }
        },
        {
          type: 'related to',
          access: { url: [{ value: 'https://your.awesome.research.ai' }] }
        },
        {
          type: 'related to',
          access: { url: [{ value: 'https://your.awesome.research.ai' }] }
        },
        {
          type: 'related to',
          note: [{ value: citation_value, type: 'preferred citation' }]
        },
        {
          type: 'related to',
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
      }
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
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          {
            name: [{ value: contributor1.full_name }],
            status: 'primary',
            role: [
              {
                value: 'event'
              },
              contributor_role
            ]
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
            role: author_roles
          },
          {
            name: [{ value: contributor3.full_name }],
            type: 'conference',
            role: [
              {
                value: 'conference'
              },
              contributor_role
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
        }
      )
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
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        event: [
          {
            type: 'publication',
            contributor: [
              {
                name: [{ value: contributor.full_name }],
                role: publisher_roles
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
        }
      )
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
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        event: [
          {
            type: 'publication',
            contributor: [
              {
                name: [{ value: contributor.full_name }],
                role: publisher_roles
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
        }
      )
    end
  end

  # NOTE: Arcadia to add h2 mapping spec for when there is a person and a publisher
  context 'when author, publisher and publication date are entered by user' do
    let(:person_contrib) { build(:person_contributor, role: 'Author') }
    let(:pub_contrib) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :published, :with_contact_emails,
            contributors: [person_contrib, pub_contrib], title: 'Test title')
    end

    it 'creates event of type publication with date' do
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          {
            name: [
              {
                structuredValue: [
                  {
                    value: person_contrib.first_name,
                    type: 'forename'
                  },
                  {
                    value: person_contrib.last_name,
                    type: 'surname'
                  }
                ]
              }
            ],
            type: person_contrib.contributor_type,
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
                role: publisher_roles
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
        }
      )
    end

    context 'when approximate creation date' do
      let(:work_version) do
        build(:work_version, :with_approximate_creation_date)
      end

      it 'creates event of type creation with approximate date' do
        expect(model[:event]).to eq(
          [
            {
              type: 'creation',
              date: [
                {
                  encoding: { code: 'edtf' },
                  value: '2020-03-08',
                  type: 'creation',
                  qualifier: 'approximate'
                }
              ]
            }
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
            {
              type: 'creation',
              date: [
                {
                  encoding: { code: 'edtf' },
                  structuredValue: [
                    { value: '2020-03-04', type: 'start', qualifier: 'approximate' },
                    { value: '2020-10-31', type: 'end', qualifier: 'approximate' }
                  ],
                  type: 'creation'
                }
              ]
            }
          ]
        )
      end
    end
  end
end
