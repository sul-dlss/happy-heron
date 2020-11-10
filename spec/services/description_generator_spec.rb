# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionGenerator do
  subject(:model) { described_class.generate(work: work) }

  let(:work) do
    build(:work, :with_creation_dates, :published, :with_keywords, :with_contributors)
  end
  let(:contrib1_name) { "#{work.contributors.first.last_name}, #{work.contributors.first.first_name}" }
  let(:contrib2_name) { "#{work.contributors[1].last_name}, #{work.contributors[1].first_name}" }
  let(:contrib3_name) { "#{work.contributors.last.last_name}, #{work.contributors.last.first_name}" }

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
      ]
    )
  end
end
