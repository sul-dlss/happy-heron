# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkObserver do
  describe "after_deposit_complete" do
    subject(:run) { described_class.after_deposit_complete(work_version, nil) }

    let(:work_version) { create(:work_version_with_work_and_collection, :with_files) }

    before do
      allow(GlobusClient).to receive(:delete_access_rule).and_return(true)
    end

    it "changes the file blobs to point at preservation" do
      expect(work_version.attached_files.map { |af| af.file.blob.service_name }).to all(eq("test"))
      files = work_version.attached_files.map { |af| af.file.blob.service.path_for(af.file.blob.key) }
      files.each do |file|
        expect(File.exist?(file)).to be true
      end
      run
      expect(work_version.attached_files.reload.map { |af| af.file.blob.service_name }).to all(eq("preservation"))
      files.each do |file|
        expect(File.exist?(file)).to be false
      end
    end
  end

  describe "after_deposit_complete of a globus deposit" do
    subject(:run) { described_class.after_deposit_complete(work_version, nil) }

    let(:work_version) { create(:work_version_with_work_and_collection, :with_files, :with_globus_endpoint) }

    before do
      allow(GlobusClient).to receive(:delete_access_rule).and_return(true)
    end

    it "requests globus to delete the access rule" do
      run
      expect(GlobusClient).to have_received(:delete_access_rule).with(path: "userid/workid/version1", user_id: nil)
    end
  end

  describe "after_deposit_complete of a non-globus upload" do
    subject(:run) { described_class.after_deposit_complete(work_version, nil) }

    let(:work_version) { create(:work_version_with_work_and_collection, :with_files) }

    before do
      allow(GlobusClient).to receive(:delete_access_rule).and_return(true)
    end

    it "does not request globus to delete an access rule" do
      expect(GlobusClient).not_to have_received(:delete_access_rule)
    end
  end
end
