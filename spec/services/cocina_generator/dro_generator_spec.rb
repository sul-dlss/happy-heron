# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::DROGenerator do
  let(:collection) { build(:collection, druid: 'druid:bc123df4567') }
  let(:model) { described_class.generate_model(work_version: work_version) }
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

  let(:license_uri) { License.find('CC0-1.0').uri }

  context 'when files are not present' do
    context 'without a druid' do
      let(:work_version) do
        build(:work_version, work_type: 'text', work: work, title: 'Test title')
      end
      let(:work) { build(:work, id: 7, collection: collection) }
      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 1,
          access: {
            access: 'world',
            download: 'world',
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
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
            note: [
              {
                value: 'test abstract',
                type: 'abstract'
              },
              {
                value: 'test citation',
                type: 'preferred citation'
              }
            ],
            form: types_form,
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}"
          },
          structural: {
            contains: [],
            isMemberOf: [collection.druid]
          }
        }
      }
    end

    it 'generates the model' do
      expect(model.to_h).to eq(expected_model)
    end
  end

  context 'with a druid' do
    let(:work_version) do
      build(:work_version, work_type: 'text', title: 'Test title', work: work)
    end
    let(:work) { build(:work, id: 7, druid: 'druid:bk123gh4567', collection: collection) }

    let(:expected_model) do
      {
        externalIdentifier: 'druid:bk123gh4567',
        type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
        label: 'Test title',
        version: 1,
        access: {
          access: 'world',
          download: 'world',
          license: license_uri,
          useAndReproductionStatement: Settings.access.use_and_reproduction_statement
        },
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
          note: [
            {
              value: 'test abstract',
              type: 'abstract'
            },
            {
              value: 'test citation',
              type: 'preferred citation'
            }
          ],
          form: types_form,
          access: { digitalRepository: [{ value: 'Stanford Digital Repository' }] },
          purl: 'https://purl.stanford.edu/bk123gh4567',
          adminMetadata: admin_metadata
        },
        identification: {
          sourceId: "hydrus:object-#{work_version.work.id}"
        },
        structural: {
          contains: [],
          isMemberOf: [collection.druid]
        }
      }
    end

    it 'generates the model' do
      expect(model.to_h).to eq expected_model
    end
  end

  context 'with a doi' do
    let(:work_version) do
      build(:work_version, work_type: 'text', title: 'Test title', work: work)
    end
    let(:work) { build(:work, id: 7, druid: 'druid:bk123gh4567', doi: '10.800/bk123gh4567', collection: collection) }

    let(:expected_model) do
      {
        externalIdentifier: 'druid:bk123gh4567',
        type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
        label: 'Test title',
        version: 1,
        access: {
          access: 'world',
          download: 'world',
          license: license_uri,
          useAndReproductionStatement: Settings.access.use_and_reproduction_statement
        },
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
          note: [
            {
              value: 'test abstract',
              type: 'summary'
            },
            {
              value: 'test citation',
              type: 'preferred citation'
            }
          ],
          form: types_form,
          access: { digitalRepository: [{ value: 'Stanford Digital Repository' }] },
          purl: 'https://purl.stanford.edu/bk123gh4567',
          adminMetadata: admin_metadata
        },
        identification: {
          sourceId: "hydrus:object-#{work_version.work.id}",
          doi: '10.800/bk123gh4567'
        },
        structural: {
          contains: [],
          isMemberOf: [collection.druid]
        }
      }
    end

    it 'generates the model' do
      expect(model.to_h).to eq expected_model
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
      let(:work_version) do
        build(:work_version, version: 1, attached_files: [attached_file], title: 'Test title', work: work)
      end
      let(:work) { build(:work, id: 7, collection: collection) }

      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 1,
          access: {
            access: 'world',
            download: 'world',
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
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
            note: [
              {
                value: 'test abstract',
                type: 'abstract'
              },
              {
                value: 'test citation',
                type: 'preferred citation'
              }
            ],
            form: types_form,
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}"
          },
          structural: {
            contains: [
              {
                label: 'MyString',
                structural: { contains: [
                  {
                    access: { access: 'world', download: 'world' },
                    administrative: { publish: true, sdrPreserve: true, shelve: true },
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
                type: 'http://cocina.sul.stanford.edu/models/resources/file.jsonld',
                version: 1
              }
            ],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        expect(model.to_h).to eq expected_model
      end
    end

    context 'with a druid' do
      let(:work_version) do
        build(:work_version, version: 1, attached_files: [attached_file], title: 'Test title', work: work)
      end
      let(:work) { build(:work, id: 7, druid: 'druid:bk123gh4567', collection: collection) }

      let(:expected_model) do
        {
          type: 'http://cocina.sul.stanford.edu/models/object.jsonld',
          label: 'Test title',
          version: 1,
          externalIdentifier: 'druid:bk123gh4567',
          access: {
            access: 'world',
            download: 'world',
            license: license_uri,
            useAndReproductionStatement: Settings.access.use_and_reproduction_statement
          },
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
            note: [
              {
                value: 'test abstract',
                type: 'abstract'
              },
              {
                value: 'test citation',
                type: 'preferred citation'
              }
            ],
            form: types_form,
            access: { digitalRepository: [{ value: 'Stanford Digital Repository' }] },
            purl: 'https://purl.stanford.edu/bk123gh4567',
            adminMetadata: admin_metadata
          },
          identification: {
            sourceId: "hydrus:object-#{work_version.work.id}"
          },
          structural: {
            contains: [
              {
                label: 'MyString',
                structural: {
                  contains: [
                    {
                      access: { access: 'world', download: 'world' },
                      administrative: { publish: true, sdrPreserve: true, shelve: true },
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
                type: 'http://cocina.sul.stanford.edu/models/resources/file.jsonld',
                externalIdentifier: 'bk123gh4567_1',
                version: 1
              }
            ],
            isMemberOf: [collection.druid]
          }
        }
      end

      it 'generates the model' do
        expect(model.to_h).to eq expected_model
      end
    end
  end
end
