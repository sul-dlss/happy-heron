# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestGenerator do
  let(:model) { described_class.generate_model(work: work) }

  context 'when files are not present' do
    let(:expected_model) do
      {
        type: 'http://cocina.sul.stanford.edu/models/document.jsonld',
        label: 'Test title',
        version: 0,
        administrative: {
          hasAdminPolicy: 'druid:zx485kb6348'
        },
        description: {
          title: [
            {
              value: 'Test title'
            }
          ],
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
    let(:work) { build(:work, id: 7, work_type: 'text') }

    it 'generates the model' do
      expect(model.to_h).to eq(expected_model)
    end
  end

  context 'when a file is present' do
    let(:expected_model) do
      {
        type: 'http://cocina.sul.stanford.edu/models/document.jsonld',
        label: 'Test title',
        version: 0,
        administrative: {
          hasAdminPolicy: 'druid:zx485kb6348'
        },
        description: {
          title: [
            {
              value: 'Test title'
            }
          ],
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
          ]
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
                  access: { access: 'stanford', download: 'none' },
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
          ]
        }
      }
    end
    let!(:blob) do
      ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
        filename: 'sul.svg',
        content_type: 'image/svg+xml'
      )
    end
    let(:attached_file) { build(:attached_file) }
    let(:work) { build(:work, id: 7, attached_files: [attached_file]) }

    before do
      # rubocop:disable RSpec/MessageChain
      allow(attached_file).to receive_message_chain(:file, :attachment, :blob).and_return(blob)
      # rubocop:enable RSpec/MessageChain
    end

    after do
      blob.destroy
    end

    it 'generates the model' do
      expect(model.to_h).to eq(expected_model)
    end
  end
end
