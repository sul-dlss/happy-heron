# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StorageMigrator do
  let(:druid) { 'druid:xx111zz2222' }
  let(:migrator) do
    described_class.new(druid: druid,
                        source: source_service,
                        target: target_service)
  end
  let(:source_service) { described_class.send(:default_source) }
  let(:target_service) { described_class.send(:default_target) }

  describe '.migrate' do
    before do
      allow(described_class).to receive(:new).and_return(migrator)
      allow(migrator).to receive(:migrate).and_return(true)
    end

    it 'calls #migrate on a new StorageMigrator instance' do
      described_class.migrate(druid: druid)
      expect(migrator).to have_received(:migrate).once
    end
  end

  describe '#migrate' do
    before do
      allow(Rails.logger).to receive(:info)
    end

    context 'with an unfindable druid' do
      it 'logs an informative message' do
        migrator.migrate
        expect(Rails.logger).to have_received(:info)
          .with('No files to migrate for deposited work (druid:xx111zz2222)')
          .once
      end

      it 'returns false' do
        expect(migrator.migrate).to be false
      end
    end

    context 'with a work that has no files' do
      before do
        create(:work, druid: druid)
      end

      it 'logs an informative message' do
        migrator.migrate
        expect(Rails.logger).to have_received(:info)
          .with("No files to migrate for deposited work (#{druid})")
          .once
      end

      it 'returns false' do
        expect(migrator.migrate).to be false
      end
    end

    context 'with a work that has one or more files' do
      let(:blob) { work.attached_files.first.blob }
      let!(:work) { create(:work, :with_attached_file, druid: druid) }

      it 'logs an informative message' do
        migrator.migrate
        expect(Rails.logger).to have_received(:info)
          .with('Migrating sul.svg blob to druid disk location for deposited work druid:xx111zz2222')
          .once
      end

      it 'migrates blobs to target and removes them from source' do
        allow(target_service).to receive(:upload)
        allow(source_service).to receive(:delete)
        migrator.migrate
        expect(target_service).to have_received(:upload).with(blob.key, anything, checksum: blob.checksum).once
        expect(source_service).to have_received(:delete).with(blob.key).once
      end

      it 'returns true' do
        expect(migrator.migrate).to be true
      end
    end
  end
end
