# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchGlobusJob do
  let(:first_work_version) do
    create(:work_version, work:, attached_files: [attached_file], version: 1,
                          state: 'fetch_globus_first_draft', upload_type: 'globus',
                          globus_endpoint: 'jstanford/work333/version1')
  end

  let(:attached_file) { build(:attached_file) }

  let(:work) { build(:work) }

  before do
    allow(GlobusClient).to receive(:get_filenames).and_return(
      [
        '/uploads/jstanford/work333/version1/file1.txt',
        '/uploads/jstanford/work333/version1/__MACOSX/._file1.txt',
        '/uploads/jstanford/work333/version1/dir1/file2.txt',
        '/uploads/jstanford/work333/version1/__MACOSX/dir1/._file2.txt',
        '/uploads/jstanford/work333/version1/dir2/.DS_Store',
        '/uploads/jstanford/work333/version1/__MACOSX/dir2/._.DS_Store'
      ]
    )
    work.update!(head: first_work_version)
  end

  it 'fetches filenames from Globus and creates attached files' do
    expect { described_class.perform_now(first_work_version) }
      .to change { first_work_version.attached_files.count }.from(1).to(2)
      .and change(first_work_version, :state).to('first_draft')
      .and change(first_work_version, :upload_type).to('browser')

    expect(AttachedFile.find_by(id: attached_file.id)).to be_nil
    attached_file = first_work_version.reload.attached_files.first
    expect(attached_file.path).to eq('file1.txt')
    expect(attached_file.blob.service_name).to eq('globus')
    expect(GlobusClient).to have_received(:get_filenames).with(path: 'jstanford/work333/version1',
                                                               user_id: work.owner.email)
  end
end
