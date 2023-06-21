# frozen_string_literal: true

require "rails_helper"

RSpec.describe NewVersionService do
  let(:new_version) do
    described_class.dup(existing_version, increment_version: true, save: true, version_description: "A dup",
      state: :version_draft)
  end

  let(:existing_version) { create(:work_version_with_work_and_collection) }

  let(:attached_file) { create(:attached_file, :with_file) }

  before do
    existing_version.update(attached_files: [attached_file])
  end

  it "duplicates the version" do
    expect(new_version).to be_a WorkVersion
    expect(new_version.persisted?).to be true
    expect(new_version.version).to be 2
    expect(new_version.version_description).to eq "A dup"
    expect(new_version.version_draft?).to be true
    existing_version.reload
    expect(new_version.title).to eq existing_version.title
    expect(new_version.work).to eq existing_version.work
    expect(existing_version.work.head).to eq new_version
    expect(new_version.attached_files.count).to eq existing_version.attached_files.count
    expect(new_version.attached_files.first.label).to eq existing_version.attached_files.first.label
    expect(new_version.attached_files.first.blob.checksum).to eq existing_version.attached_files.first.blob.checksum
    expect(new_version.keywords.count).to eq existing_version.keywords.count
    expect(new_version.keywords.first.label).to eq existing_version.keywords.first.label
    expect(new_version.authors.count).to eq existing_version.authors.count
  end
end
