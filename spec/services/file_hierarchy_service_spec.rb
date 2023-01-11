# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileHierarchyService do
  subject(:root_directory) { described_class.to_hierarchy(work_version:) }

  let(:paths) do
    [
      'dir1/dir2/file12.pdf',
      'dir1/dir3/file13.pdf',
      'dir1/file1.pdf',
      'dir1/file2.pdf',
      'dir1/file3.pdf',
      'file4.pdf'
    ]
  end
  let(:attached_files) { paths.map { |path| create(:attached_file, path:) } }
  let(:work_version) { build(:work_version, attached_files:) }

  before do
    attached_files.each_with_index do |attached_file, i|
      allow(attached_file).to receive(:filename).and_return(paths[i])
    end
  end

  # rubocop:disable Layout/ArgumentAlignment
  it 'returns a hash of the file hierarchy' do
    expect(root_directory).to match(
      FileHierarchyService::Directory.new('',
        [
          FileHierarchyService::Directory.new('dir1',
            [
              FileHierarchyService::Directory.new('dir2', [],
                [
                  FileHierarchyService::File.new(attached_files[0])
                ], 2),
              FileHierarchyService::Directory.new('dir3', [],
                [
                  FileHierarchyService::File.new(attached_files[1])
                ], 2)
            ],
            [
              FileHierarchyService::File.new(attached_files[2]),
              FileHierarchyService::File.new(attached_files[3]),
              FileHierarchyService::File.new(attached_files[4])
            ], 1)
        ],
        [
          FileHierarchyService::File.new(attached_files[5])
        ], 0)
    )
  end
  # rubocop:enable Layout/ArgumentAlignment
end
