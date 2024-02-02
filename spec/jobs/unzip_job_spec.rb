# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnzipJob do
  let(:first_work_version) do
    create(:work_version, work:, attached_files: [attached_file1, attached_file2, zip_attached_file], version: 1,
                          state: 'unzip_first_draft', upload_type: 'zipfile')
  end

  let(:attached_file1) { build(:attached_file) }
  let(:attached_file2) { build(:attached_file) }
  let(:zip_attached_file) { build(:attached_file) }

  let(:work) { build(:work) }
  let(:zip_path) { 'tmp/folder3.zip' }

  before do
    allow(ActiveStorage::Blob.service).to receive(:path_for).and_return(zip_path)
    allow(zip_attached_file).to receive_message_chain(:file, :blob).and_return(blob) # rubocop:disable RSpec/MessageChain
    FileUtils.cp('spec/fixtures/files/folder3.zip', zip_path)
    work.update!(head: first_work_version)
  end

  context 'when the attached file is on the file system' do
    before { allow(zip_attached_file).to receive(:in_globus?).and_return(false) }

    context 'when the attached file is a zip file' do
      # simulate the attached file is actually a zip file
      let(:blob) { instance_double(ActiveStorage::Blob, key: '123', content_type: 'application/zip') }

      it 'unzips the attached file' do
        expect { described_class.perform_now(first_work_version) }
          .to change { first_work_version.attached_files.count }.from(3).to(2)
          .and change(first_work_version, :state).to('first_draft')
          .and change(first_work_version, :upload_type).to('browser')

        expect(ActiveStorage::Blob.service).to have_received(:path_for).with('123')
        expect(AttachedFile.find_by(id: zip_attached_file.id)).to be_nil # the zipped file is destroyed
        expect(AttachedFile.find_by(id: attached_file1.id)).to be_nil # the attached file is destroyed
      end
    end

    context 'when the attached file is not a zip file' do
      # simulate the attached file is not a zip file
      let(:blob) { instance_double(ActiveStorage::Blob, key: '123', content_type: 'image/svg+xml') }

      it 'just reverts back to browser upload type' do
        expect { described_class.perform_now(first_work_version) }
          .to change(first_work_version, :state).to('first_draft')
          .and change(first_work_version, :upload_type).to('browser')
        expect(first_work_version.attached_files.count).to eq 3 # still three files
        expect(ActiveStorage::Blob.service).not_to have_received(:path_for).with('123')
        expect(AttachedFile.find_by(id: zip_attached_file.id)).to eq zip_attached_file # existing files are not touched
        expect(AttachedFile.find_by(id: attached_file1.id)).to eq attached_file1
      end
    end
  end

  context 'when the attached file is in globus' do
    before { allow(zip_attached_file).to receive(:in_globus?).and_return(true) }

    context 'when the attached file is a zip file' do
      # simulate the attached file is actually a zip file
      let(:blob) { instance_double(ActiveStorage::Blob, key: '123', content_type: 'application/zip') }

      it 'just reverts back to browser upload type' do
        expect { described_class.perform_now(first_work_version) }
          .to change(first_work_version, :state).to('first_draft')
          .and change(first_work_version, :upload_type).to('browser')
        expect(first_work_version.attached_files.count).to eq 3 # still three files
        expect(ActiveStorage::Blob.service).not_to have_received(:path_for).with('123')
        expect(AttachedFile.find_by(id: zip_attached_file.id)).to eq zip_attached_file # existing files are not touched
        expect(AttachedFile.find_by(id: attached_file1.id)).to eq attached_file1
      end
    end
  end
end
