# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionGenerator do
  subject(:model) { described_class.generate(work: work).to_h }

  let(:contributor) { build(:contributor, :with_org_contributor) }
  let(:work) do
    build(:work, :with_creation_dates, :published, :with_keywords,
          :with_some_untitled_related_links, :with_related_works,
          contributors: [contributor])
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
            value: 'Presentation slides'
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
        value: 'Presentation slides'
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

  it 'creates description cocina model' do
    expect(model).to eq(
      event: [
        { date: [{ encoding: { code: 'edtf' }, value: '2020-03-04/2020-10-31' }], type: 'creation' },
        { date: [{ encoding: { code: 'edtf' }, value: '2020-02-14' }], type: 'publication' }
      ],
      subject: [
        { type: 'topic', value: 'MyString' },
        { type: 'topic', value: 'MyString' },
        { type: 'topic', value: 'MyString' }
      ],
      note: [
        { type: 'summary', value: 'test abstract' },
        { type: 'preferred citation', value: 'test citation' },
        { displayLabel: 'Contact', type: 'contact', value: 'io@io.io' }
      ],
      title: [{ value: 'Test title' }],
      contributor: [
        {
          name: [{ value: contributor.full_name }],
          type: contributor.contributor_type,
          role: [
            {
              value: contributor.role,
              source: {
                value: 'Stanford self-deposit contributor types'
              }
            },
            {
              value: 'sponsor',
              code: 'spn',
              uri: 'http://id.loc.gov/vocabulary/relators/spn',
              source: {
                code: 'marcrelator',
                uri: 'http://id.loc.gov/vocabulary/relators/'
              }
            },
            {
              value: 'Sponsor',
              source: {
                value: 'DataCite contributor types'
              }
            }
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
      form: types_form
    )
  end

  context 'when contributor of type conference or event' do
    let(:contributor1) { build(:contributor, :with_org_contributor, role: 'Event') }
    let(:contributor2) { build(:contributor, role: 'Author') }
    let(:contributor3) { build(:contributor, :with_org_contributor, role: 'Conference') }
    let(:work) { build(:work, contributors: [contributor1, contributor2, contributor3]) }
    let(:stanford_self_deposit_source) do
      {
        value: 'Stanford self-deposit contributor types'
      }
    end
    let(:marc_relator_source) do
      {
        code: 'marcrelator',
        uri: 'http://id.loc.gov/vocabulary/relators/'
      }
    end
    let(:datacite_creator_role) do
      {
        value: 'Creator',
        source: {
          value: 'DataCite properties'
        }
      }
    end
    let(:author_roles) do
      [
        {
          value: 'Author',
          source: stanford_self_deposit_source
        },
        {
          value: 'author',
          code: 'aut',
          uri: 'http://id.loc.gov/vocabulary/relators/aut',
          source: marc_relator_source
        },
        datacite_creator_role
      ]
    end
    let(:event_form) do
      [
        {
          value: 'Event',
          type: 'resource types',
          source: {
            value: 'DataCite resource types'
          }
        }
      ]
    end

    it 'creates forms as well as contributors in description cocina model' do
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' },
          { displayLabel: 'Contact', type: 'contact', value: 'io@io.io' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          {
            name: [{ value: contributor1.full_name }],
            type: 'event',
            role: [
              {
                value: 'Event',
                source: stanford_self_deposit_source
              }
            ]
          },
          {
            name: [
              {
                value: "#{contributor2.last_name}, #{contributor2.first_name}",
                type: 'inverted full name'
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
                value: 'Conference',
                source: stanford_self_deposit_source
              }
            ]
          }
        ],
        form: types_form + event_form,
        event: [],
        subject: [],
        relatedResource: []
      )
    end
  end
end
