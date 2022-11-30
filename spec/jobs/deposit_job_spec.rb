# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include Dry::Monads[:result]

  let(:conn) { instance_double(SdrClient::Connection) }
  let!(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/sul.svg').open,
      filename: 'sul.svg',
      content_type: 'image/svg+xml;version=14'
    )
  end
  let(:attached_file) { build(:attached_file) }
  let(:work) { build(:work, collection:, assign_doi: false) }
  let(:first_work_version) do
    build(:work_version, work:, attached_files: [attached_file], version: 1)
  end

  let(:collection) { build(:collection, druid: 'druid:bc123df4567', doi_option: 'depositor-selects') }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(Success())
    allow(SdrClient::Connection).to receive(:new).and_return(conn)
    allow(Honeybadger).to receive(:notify)
    # rubocop:disable RSpec/MessageChain
    allow(attached_file).to receive_message_chain(:file, :blob).and_return(blob)
    # rubocop:enable RSpec/MessageChain
  end

  after do
    blob.destroy
  end

  context 'when creating a new deposit is successful' do
    before do
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_return(1234)
      allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
        .and_return([SdrClient::Deposit::Files::DirectUploadResponse.new(filename: 'sul.svg',
                                                                         signed_id: '9999999')])
    end

    let(:upload_request) do
      SdrClient::Deposit::Files::DirectUploadRequest.new(
        checksum: '9e/54o8VT3n3oRJhvA1LMA==', byte_size: 17_675, content_type: 'image/svg+xml', filename: 'sul.svg'
      )
    end

    it 'uploads files and calls CreateResource.run' do
      described_class.perform_now(first_work_version)
      expect(SdrClient::Deposit::CreateResource).to have_received(:run)
        .with(a_hash_including(accession: true)) do |params|
        file = params[:metadata].structural.contains.first.structural.contains.first
        expect(file.externalIdentifier).to eq('9999999')
        expect(file.filename).to eq('sul.svg')
      end
      expect(SdrClient::Deposit::UploadFiles).to have_received(:upload) do |args|
        expect(args[:file_metadata].values.first.to_h).to eq(upload_request.to_h)
      end
    end

    context 'when the deposit wants a doi' do
      let(:work) { build(:work, collection:, assign_doi: true) }

      it 'calls CreateResource.run with true for the assign_doi param' do
        described_class.perform_now(first_work_version)
        expect(SdrClient::Deposit::CreateResource).to have_received(:run)
          .with(a_hash_including(accession: true, assign_doi: true))
      end
    end
  end

  context 'when updating the deposit' do
    let(:work) { build(:work, collection:, assign_doi: false, druid:) }
    let(:druid) { 'druid:bf024yb8975' }
    let(:second_work_version) do
      build(:work_version, work:, attached_files: [attached_file2], version: 2, version_description: 'Changed files')
    end
    let(:attached_file2) { build(:attached_file) }
    let!(:blob2) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sul.svg').open,
        filename: 'sul2.svg',
        content_type: 'image/svg+xml'
      )
    end
    # The job fetches the existing cocina model from the SDR API to copy structural > contains.
    let(:cocina) do
      {
        cocinaVersion: Cocina::Models::VERSION,
        externalIdentifier: druid,
        type: Cocina::Models::ObjectType.book,
        label: 'Test DRO',
        version: 1,
        description: {
          title: [{ value: 'Test DRO' }],
          purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
        },
        access: { view: 'world', download: 'world' },
        administrative: { hasAdminPolicy: 'druid:hy787xj5878' },
        identification: { sourceId: 'sul:abc123' },
        structural: { contains: [
          {
            type: Cocina::Models::FileSetType.file,
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/123-456-789', label: 'Page 1', version: 1,
            structural: {
              contains: [
                {
                  type: Cocina::Models::ObjectType.file,
                  externalIdentifier: 'https://cocina.sul.stanford.edu/file/123-456-789',
                  label: 'An image',
                  filename: 'sul.svg',
                  size: 0,
                  version: 1,
                  hasMimeType: 'text/html',
                  use: 'transcription',
                  hasMessageDigests: [
                    {
                      type: 'sha1', digest: 'cb19c405f8242d1f9a0a6180122dfb69e1d6e4c7'
                    }, {
                      type: 'md5', digest: 'f5eff9e28f154f79f7a11261bc0d4b30'
                    }
                  ],
                  access: { view: 'dark' },
                  administrative: { publish: false, sdrPreserve: true, shelve: false }
                }
              ]
            }
          }
        ] }
      }
    end

    before do
      allow(SdrClient::Deposit::UpdateResource).to receive(:run).and_return(1234)
      allow(SdrClient::Find).to receive(:run).and_return(cocina.to_json)

      # This emulates the behavior of the DepositCompleteJob:
      blob.update!(service_name: ActiveStorage::Service::SdrService::SERVICE_NAME)

      # rubocop:disable RSpec/MessageChain
      allow(attached_file2).to receive_message_chain(:file, :blob).and_return(blob2)
      # rubocop:enable RSpec/MessageChain
    end

    context 'when files have not changed' do
      # The attached files for this version are the same as the previous version.
      let(:second_work_version_metadata_only) do
        build(:work_version, work:, attached_files: [attached_file], version: 2,
                             version_description: 'Updated metadata')
      end

      before do
        work.work_versions = [first_work_version, second_work_version_metadata_only]
      end

      it 'calls UpdateResource.run' do
        described_class.perform_now(second_work_version_metadata_only)

        # Notice that UpdateResource.run is called but UploadFiles.upload is not.
        # This makes this a "metadata only" update.
        expect(SdrClient::Deposit::UpdateResource).to have_received(:run)
          .with(a_hash_including(version_description: 'Updated metadata')) do |params|
          external_identifier = params[:metadata].structural.contains.first.structural.contains.first.externalIdentifier
          expect(external_identifier).to eq('https://cocina.sul.stanford.edu/file/123-456-789')
        end
      end
    end

    context 'when files have changed' do
      before do
        allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
          .and_return([SdrClient::Deposit::Files::DirectUploadResponse.new(filename: 'sul2.svg',
                                                                           signed_id: '9999999')])
      end

      it 'uploads files and calls UpdateResource.run' do
        described_class.perform_now(second_work_version)
        expect(SdrClient::Deposit::UpdateResource).to have_received(:run)
          .with(a_hash_including(version_description: 'Changed files')) do |params|
          external_identifier = params[:metadata].structural.contains.first.structural.contains.first.externalIdentifier
          expect(external_identifier).to eq('9999999')
        end

        expect(SdrClient::Deposit::UploadFiles).to have_received(:upload)
      end
    end

    context 'when file description has changed' do
      # The attached files for this version are the same as the previous version
      let(:attached_file) { build(:attached_file, label: 'My changed label') }
      let(:second_work_version_metadata_only) do
        build(:work_version, work:, attached_files: [attached_file], version: 2,
                             version_description: 'Updated metadata')
      end

      before do
        work.work_versions = [first_work_version, second_work_version_metadata_only]
      end

      it 'calls UpdateResource.run and uses updated metadata' do
        described_class.perform_now(second_work_version_metadata_only)

        # Notice that UpdateResource.run is called but UploadFiles.upload is not.
        # This makes this a "metadata only" update.
        expect(SdrClient::Deposit::UpdateResource).to have_received(:run)
          .with(a_hash_including(version_description: 'Updated metadata')) do |params|
          external_identifier = params[:metadata].structural.contains.first.structural.contains.first.externalIdentifier
          label = params[:metadata].structural.contains.first.structural.contains.first.label
          expect(external_identifier).to eq('https://cocina.sul.stanford.edu/file/123-456-789')
          expect(label).to eq('My changed label')
        end
      end
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_raise('Deposit failed.')
      allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
        .and_return([SdrClient::Deposit::Files::DirectUploadResponse.new(filename: 'sul.svg', signed_id: '9999999')])
    end

    it 'notifies' do
      expect { described_class.perform_now(first_work_version) }.to raise_error(RuntimeError, 'Deposit failed.')
      expect(SdrClient::Deposit::UploadFiles).to have_received(:upload)
    end
  end
end
