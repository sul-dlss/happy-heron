# typed: false
# frozen_string_literal: true

require 'rails_helper'
require 'active_storage/service/druid_disk_service' # because Rails doesn't auto-load this

RSpec.describe ActiveStorage::Service::DruidDiskService do
  subject(:service) { described_class.new(root: '/tmp') }

  it { is_expected.to be_an(ActiveStorage::Service::DiskService) }

  describe '#folder_for' do
    let(:druid) { 'druid:bc123df4567' }
    # The key is an ActiveStorage-created identifier (unique, opaque, and immutable)
    let(:key) { work.attached_files.first.blob.key }
    let(:work) { create(:work, :with_attached_file, druid: druid) }

    it 'returns a druid tree path' do
      expect(service.send(:folder_for, key)).to eq('./bc/123/df/4567/bc123df4567')
    end
  end
end
