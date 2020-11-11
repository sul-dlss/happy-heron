# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionGenerator do
  subject(:model) { described_class.generate(work: work) }

  let(:work) do
    build(:work, :with_creation_dates, :published, :with_keywords, :with_contributors,
          :with_some_untitled_related_links, :with_related_works)
  end
  let(:contrib1_name) { "#{work.contributors.first.last_name}, #{work.contributors.first.first_name}" }
  let(:contrib2_name) { "#{work.contributors[1].last_name}, #{work.contributors[1].first_name}" }
  let(:contrib3_name) { "#{work.contributors.last.last_name}, #{work.contributors.last.first_name}" }
  let(:citation_value) do
    'Giarlo, M.J. (2013). Academic Libraries as Data Quality Hubs. '\
        'Journal of Librarianship and Scholarly Communication, 1(3).'
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
        { name: [{ value: contrib1_name }], role: [{ value: 'Contributing author' }], type: 'person' },
        { name: [{ value: contrib2_name }], role: [{ value: 'Contributing author' }], type: 'person' },
        { name: [{ value: contrib3_name }], role: [{ value: 'Contributing author' }], type: 'person' }
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
      ]
    )
  end

  context 'with mixed contributors' do
    let(:work) do
      build(:work, :with_mixed_contributors)
    end
    let(:contrib1_name) { "#{work.contributors.first.last_name}, #{work.contributors.first.first_name}" }
    let(:contrib2_name) { work.contributors.last.full_name }

    it 'creates description cocina model for org contribtor' do
      expect(model).to eq(
        note: [
          { type: 'summary', value: 'test abstract' },
          { type: 'preferred citation', value: 'test citation' },
          { displayLabel: 'Contact', type: 'contact', value: 'io@io.io' }
        ],
        title: [{ value: 'Test title' }],
        contributor: [
          { name: [{ value: contrib1_name }], role: [{ value: 'Contributing author' }], type: 'person' },
          { name: [{ value: contrib2_name }], role: [{ value: 'Sponsor' }], type: 'organization' }
        ],
        event: [],
        subject: [],
        relatedResource: []
      )
    end
  end
end
