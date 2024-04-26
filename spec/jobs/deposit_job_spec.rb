# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include Dry::Monads[:result]

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
    allow(Honeybadger).to receive(:notify)
    allow(attached_file).to receive_message_chain(:file, :blob).and_return(blob) # rubocop:disable RSpec/MessageChain
  end

  after do
    blob.destroy
  end

  context 'when creating a new deposit is successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_return(1234)
    end

    it 'deposits the work via sdr-client' do
      described_class.perform_now(first_work_version)
      expect(SdrClient::RedesignedClient).to have_received(:deposit_model)
        .with(a_hash_including(accession: true, user_versions: 'none')) do |params|
        file = params[:model].structural.contains.first.structural.contains.first
        expect(file.hasMimeType).to eq('image/svg+xml')
        expect(file.size).to eq(17_675)
        expect(file.filename).to eq('sul.svg')
      end
    end

    context 'when user versions is enabled' do
      before do
        allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
      end

      it 'uploads files and calls CreateResource.run' do
        described_class.perform_now(first_work_version)
        expect(SdrClient::RedesignedClient).to have_received(:deposit_model)
          .with(a_hash_including(accession: true, user_versions: 'new'))
      end
    end

    context 'when the deposit wants a doi' do
      let(:work) { build(:work, collection:, assign_doi: true) }

      it 'deposits the work via sdr-client with the assign_doi param' do
        described_class.perform_now(first_work_version)
        expect(SdrClient::RedesignedClient).to have_received(:deposit_model)
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
    let(:attached_file2) { build(:attached_file, path: 'sul2.svg') }
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
            externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/bk123gh4567-123456',
            label: 'Page 1',
            version: 1,
            structural: {
              contains: [
                {
                  type: Cocina::Models::ObjectType.file,
                  externalIdentifier: 'https://cocina.sul.stanford.edu/file/bk123gh4567-123456/sul.svg',
                  label: 'An image',
                  filename: 'sul.svg',
                  size: 123,
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
      allow(SdrClient::RedesignedClient).to receive_messages(update_model: 1234, find: cocina.to_json)

      # This emulates the behavior of the DepositCompleteJob:
      blob.update!(service_name: ActiveStorage::Service::SdrService::SERVICE_NAME)

      allow(attached_file2).to receive_message_chain(:file, :blob).and_return(blob2) # rubocop:disable RSpec/MessageChain
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
        expect(SdrClient::RedesignedClient).to have_received(:update_model)
          .with(a_hash_including(version_description: 'Updated metadata')) do |params|
          external_identifier = params[:model].structural.contains.first.structural.contains.first.externalIdentifier
          expect(external_identifier).to eq('https://cocina.sul.stanford.edu/file/bk123gh4567-123456/sul.svg')
        end
      end

      context 'when file description has changed' do
        let(:attached_file_updated) { build(:attached_file, :with_preserved_file, label: 'My changed label') }
        let(:second_work_version_metadata_only) do
          build(:work_version, work:, attached_files: [attached_file_updated], version: 2,
                               version_description: 'Updated metadata')
        end

        before do
          work.work_versions = [first_work_version, second_work_version_metadata_only]
          allow(SdrClient::Find).to receive(:run).and_return(cocina.to_json)
        end

        it 'calls UpdateResource.run and uses updated label' do
          described_class.perform_now(second_work_version_metadata_only)

          # Notice that UpdateResource.run is called but UploadFiles.upload is not.
          # This makes this a "metadata only" update.
          expect(SdrClient::RedesignedClient).to have_received(:update_model)
            .with(a_hash_including(version_description: 'Updated metadata')) do |params|
            external_identifier =
              params[:model].structural.contains.first.structural.contains.first.externalIdentifier
            label = params[:model].structural.contains.first.structural.contains.first.label
            size = params[:model].structural.contains.first.structural.contains.first.size
            has_mime_type = params[:model].structural.contains.first.structural.contains.first.hasMimeType
            expect(external_identifier).to eq('https://cocina.sul.stanford.edu/file/bk123gh4567-123456/sul.svg')
            expect(label).to eq('My changed label')
            expect(size).to eq(123)
            expect(has_mime_type).to eq('text/html')
          end
        end
      end
    end

    context 'when files have changed' do
      before do
        allow(blob2).to receive(:signed_id).and_return('9999999')
      end

      it 'uploads files and calls UpdateResource.run' do
        described_class.perform_now(second_work_version)
        expect(SdrClient::RedesignedClient).to have_received(:update_model)
          .with(a_hash_including(version_description: 'Changed files')) do |params|
          external_identifier = params[:model].structural.contains.first.structural.contains.first.externalIdentifier
          size = params[:model].structural.contains.first.structural.contains.first.size
          has_mime_type = params[:model].structural.contains.first.structural.contains.first.hasMimeType
          expect(external_identifier).to eq('9999999')
          expect(size).to eq(17_675)
          expect(has_mime_type).to eq('image/svg+xml')
        end
      end
    end

    context 'when a file is added to an existing deposit' do
      let(:second_work_version) do
        build(:work_version, work:, attached_files: [attached_file, attached_file2], version: 2,
                             version_description: 'Added file')
      end

      before do
        work.work_versions = [first_work_version, second_work_version]
        allow(SdrClient::RedesignedClient).to receive(:find).and_return(cocina.to_json)
        allow(blob2).to receive(:signed_id).and_return('9999999')
      end

      it 'uploads files and calls UpdateResource.run' do
        described_class.perform_now(second_work_version)
        expect(SdrClient::RedesignedClient).to have_received(:update_model)
          .with(a_hash_including(version_description: 'Added file')) do |params|
          # file from version1
          external_identifier = params[:model].structural.contains.first.structural.contains.first.externalIdentifier
          size = params[:model].structural.contains.first.structural.contains.first.size
          has_mime_type = params[:model].structural.contains.first.structural.contains.first.hasMimeType
          expect(external_identifier).to eq('https://cocina.sul.stanford.edu/file/bk123gh4567-123456/sul.svg')
          expect(size).to eq(123)
          expect(has_mime_type).to eq('text/html')
          # new file
          external_identifier2 =
            params[:model].structural.contains.second.structural.contains.first.externalIdentifier
          size2 = params[:model].structural.contains.second.structural.contains.first.size
          has_mime_type2 = params[:model].structural.contains.second.structural.contains.first.hasMimeType
          expect(external_identifier2).to eq('9999999')
          expect(size2).to eq(17_675)
          expect(has_mime_type2).to eq('image/svg+xml')
        end
      end
    end

    context 'when a file with the same name is replaced on a deposit' do
      let(:attached_file2) { build(:attached_file) }
      let(:second_work_version) do
        build(:work_version, work:, attached_files: [attached_file2], version: 2,
                             version_description: 'Replaced file')
      end
      let!(:blob2) do
        ActiveStorage::Blob.create_and_upload!(
          io: Rails.root.join('spec/fixtures/files/sul.svg').open,
          filename: 'sul.svg',
          content_type: 'image/svg+xml'
        )
      end

      before do
        work.work_versions = [first_work_version, second_work_version]
        allow(SdrClient::RedesignedClient).to receive(:find).and_return(cocina.to_json)
        allow(blob2).to receive(:signed_id).and_return('9999999')
        blob.update!(service_name: ActiveStorage::Service::SdrService::SERVICE_NAME)

        allow(attached_file2).to receive_message_chain(:file, :blob).and_return(blob2) # rubocop:disable RSpec/MessageChain
      end

      it 'uploads the replaced file and calls UpdateResource.run' do
        described_class.perform_now(second_work_version)
        expect(SdrClient::RedesignedClient).to have_received(:update_model)
          .with(a_hash_including(version_description: 'Replaced file')) do |params|
          # should use blob metadata not retrieved cocina
          external_identifier = params[:model].structural.contains.first.structural.contains.first.externalIdentifier
          size = params[:model].structural.contains.first.structural.contains.first.size
          has_mime_type = params[:model].structural.contains.first.structural.contains.first.hasMimeType
          expect(external_identifier).to eq('9999999')
          expect(size).to eq(17_675)
          expect(has_mime_type).to eq('image/svg+xml')
        end
      end
    end

    context 'when user versions is enabled' do
      # The attached files for this version are the same as the previous version.
      let(:second_work_version_metadata_only) do
        build(:work_version, work:, attached_files: [attached_file], version: 2,
                             version_description: 'Updated metadata')
      end

      before do
        work.work_versions = [first_work_version, second_work_version_metadata_only]
        allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
      end

      it 'calls UpdateResource.run' do
        described_class.perform_now(second_work_version_metadata_only)

        expect(SdrClient::RedesignedClient).to have_received(:update_model)
          .with(a_hash_including(version_description: 'Updated metadata', user_versions: 'update'))
      end
    end
  end

  context 'when the deposit is a globus deposit' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_return(1234)
      allow(GlobusClient).to receive(:disallow_writes).and_return(true)
    end

    let(:first_work_version) do
      build(:work_version, :with_globus_endpoint_draft, work:, attached_files: [attached_file], version: 1)
    end

    it 'updates globus permissions' do
      described_class.perform_now(first_work_version)
      expect(GlobusClient).to have_received(:disallow_writes).with(path: 'userid/workid/version1', user_id: nil)
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_raise('Deposit failed.')
    end

    it 'notifies' do
      expect { described_class.perform_now(first_work_version) }.to raise_error(RuntimeError, 'Deposit failed.')
    end
  end
end
