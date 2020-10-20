# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestGenerator do
  let(:work) { create(:work) }

  let(:model) { described_class.generate_model(work: work) }

  let(:expected_model) do
    {
      type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
      label: 'Test title',
      version: 0,
      administrative: {
        hasAdminPolicy: 'druid:pq757cd0790'
      },
      description: {
        title: [
          {
            value: 'Test title'
          }
        ],
        event: [
          {
            type: 'creation',
            date: [
              {
                value: '1900',
                encoding: {
                  code: 'edtf'
                }
              }
            ]
          }
        ],
        note: [
          {
            value: 'test abstract',
            type: 'summary'
          },
          {
            value: 'test citation',
            type: 'preferred citation'
          },
          {
            value: 'io@io.io',
            type: 'contact',
            displayLabel: 'Contact'
          }
        ]
      },
      identification: {
        sourceId: "hydrus:#{work.id}"
      },
      structural: {
        contains: []
      }
    }
  end

  it 'generates the model' do
    expect(model.to_h).to eq(expected_model)
  end
end
