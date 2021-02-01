# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestGenerator do
  let(:collection) { build(:collection, druid: 'druid:bc123df4567') }
  let(:model) { described_class.generate_model(work: work) }
  let(:project_tag) { Settings.h2.project_tag }
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
            value: 'Government document'
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
        source: {
          code: 'aat'
        },
        type: 'genre',
        value: 'government records',
        uri: 'http://vocab.getty.edu/aat/300027777'
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

  context 'when files are not present' do
    context 'without a druid' do
      let(:work) do
        build(:work, id: 7, work_type: 'text', collection: collection, title: 'Test title')
      end
      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 0,
          access: { access: 'world', download: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348',
            partOfProject: project_tag
          },
          description: {
            title: [
              {
                value: 'Test title'
              }
            ],
            contributor: [],
            event: [],
            subject: [],
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
            ],
            relatedResource: [],
            form: types_form
          },
          identification: {
            sourceId: "hydrus:#{work.id}"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        expect(model).to eq Cocina::Models::RequestDRO.new(expected_model)
      end
    end

    context 'with a druid' do
      let(:work) do
        build(:work, id: 7, work_type: 'text', druid: 'druid:bk123gh4567',
                     title: 'Test title', collection: collection)
      end
      let(:expected_model) do
        {
          externalIdentifier: 'druid:bk123gh4567',
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 0,
          access: { access: 'world', download: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348',
            partOfProject: project_tag
          },
          description: {
            title: [
              {
                value: 'Test title'
              }
            ],
            contributor: [],
            event: [],
            subject: [],
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
            ],
            relatedResource: [],
            form: types_form
          },
          identification: {
            sourceId: "hydrus:#{work.id}"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        expect(model).to eq Cocina::Models::DRO.new(expected_model)
      end
    end
  end

  context 'when a file is present' do
    let!(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
        filename: 'sul.svg',
        content_type: 'image/svg+xml'
      )
    end
    let(:attached_file) { build(:attached_file) }

    before do
      # rubocop:disable RSpec/MessageChain
      allow(attached_file).to receive_message_chain(:file, :attachment, :blob).and_return(blob)
      # rubocop:enable RSpec/MessageChain
    end

    after do
      blob.destroy
    end

    context 'without a druid' do
      let(:work) do
        build(:work, id: 7, version: 1, attached_files: [attached_file], collection: collection, title: 'Test title')
      end
      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 1,
          access: { access: 'world', download: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348',
            partOfProject: project_tag
          },
          description: {
            title: [
              {
                value: 'Test title'
              }
            ],
            event: [],
            contributor: [],
            subject: [],
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
            ],
            relatedResource: [],
            form: types_form
          },
          identification: {
            sourceId: "hydrus:#{work.id}"
          },
          structural: {
            contains: [
              {
                label: 'MyString',
                structural: { contains: [
                  {
                    access: { access: 'world', download: 'world' },
                    administrative: { sdrPreserve: true, shelve: true },
                    filename: 'sul.svg',
                    hasMessageDigests: [
                      { digest: 'f5eff9e28f154f79f7a11261bc0d4b30', type: 'md5' },
                      { digest: '2046f6584c2f0f5e9c0df7e8070d14d1ec65f382', type: 'sha1' }
                    ],
                    hasMimeType: 'image/svg+xml',
                    label: 'MyString',
                    size: 17_675,
                    type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
                    version: 1
                  }
                ] },
                type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
                version: 1
              }
            ],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        expect(model).to eq Cocina::Models::RequestDRO.new(expected_model)
      end
    end

    context 'with a druid' do
      let(:work) do
        build(:work, id: 7, version: 1, attached_files: [attached_file],
                     druid: 'druid:bk123gh4567',
                     collection: collection,
                     title: 'Test title')
      end
      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 1,
          externalIdentifier: 'druid:bk123gh4567',
          access: { access: 'world', download: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348',
            partOfProject: project_tag
          },
          description: {
            title: [
              {
                value: 'Test title'
              }
            ],
            event: [],
            contributor: [],
            subject: [],
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
            ],
            relatedResource: [],
            form: types_form
          },
          identification: {
            sourceId: "hydrus:#{work.id}"
          },
          structural: {
            contains: [
              {
                label: 'MyString',
                structural: {
                  contains: [
                    {
                      access: { access: 'world', download: 'world' },
                      administrative: { sdrPreserve: true, shelve: true },
                      filename: 'sul.svg',
                      hasMessageDigests: [
                        { digest: 'f5eff9e28f154f79f7a11261bc0d4b30', type: 'md5' },
                        { digest: '2046f6584c2f0f5e9c0df7e8070d14d1ec65f382', type: 'sha1' }
                      ],
                      hasMimeType: 'image/svg+xml',
                      label: 'MyString',
                      size: 17_675,
                      type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
                      externalIdentifier: 'druid:bk123gh4567/sul.svg',
                      version: 1
                    }
                  ]
                },
                type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
                externalIdentifier: 'bk123gh4567_1',
                version: 1
              }
            ],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        # expect(model).to eq Cocina::Models::DRO.new(expected_model)
        expect(model.to_h).to eq expected_model
      end
    end
  end
end
