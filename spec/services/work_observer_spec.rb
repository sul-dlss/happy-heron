# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkObserver do
  describe 'after_deposit_complete' do
    subject(:run) { described_class.after_deposit_complete(work_version, nil) }

    let(:work_version) { create(:work_version_with_work_and_collection, :with_files) }

    it 'changes the file blobs to point at preservation' do
      expect(work_version.attached_files.map { |af| af.file.blob.service_name }).to all(eq('test'))
      files = work_version.attached_files.map { |af| af.file.blob.service.path_for(af.file.blob.key) }
      files.each do |file|
        expect(File.exist?(file)).to be true
      end
      run
      expect(work_version.attached_files.reload.map { |af| af.file.blob.service_name }).to all(eq('preservation'))
      files.each do |file|
        expect(File.exist?(file)).to be false
      end
    end
  end
end
