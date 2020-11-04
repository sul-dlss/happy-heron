# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptionGenerator do
  subject(:model) { described_class.generate(work: work) }

  let(:work) do
    build(:work, :with_creation_dates, :published)
  end

  it 'makes the descripion' do
    expect(model).to eq(
      event: [
        { date: [{ encoding: { code: 'edtf' }, value: '2020-03-04/2020-10-31' }], type: 'creation' },
        { date: [{ encoding: { code: 'edtf' }, value: '2020-02-14' }], type: 'publication' }
      ],
      note: [
        { type: 'summary', value: 'test abstract' },
        { type: 'preferred citation', value: 'test citation' },
        { displayLabel: 'Contact', type: 'contact', value: 'io@io.io' }
      ],
      title: [{ value: 'Test title' }]
    )
  end
end
