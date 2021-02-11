# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include Dry::Monads[:result]

  let(:conn) { instance_double(SdrClient::Connection) }
  let!(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
      filename: 'sul.svg',
      content_type: 'image/svg+xml'
    )
  end
  let(:attached_file) { build(:attached_file) }
  let(:work) { build(:work, collection: collection) }
  let(:work_version) do
    build(:work_version, id: 8, work: work, attached_files: [attached_file])
  end
  let(:collection) { build(:collection, druid: 'druid:bc123df4567') }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(Success())
    allow(SdrClient::Connection).to receive(:new).and_return(conn)
    allow(DepositStatusJob).to receive(:perform_later)
    allow(Honeybadger).to receive(:notify)
    # rubocop:disable RSpec/MessageChain
    allow(attached_file).to receive_message_chain(:file, :attachment, :blob).and_return(blob)
    # rubocop:enable RSpec/MessageChain
  end

  after do
    blob.destroy
  end

  context 'when the deposit request is successful' do
    before do
      allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
        .and_return([SdrClient::Deposit::Files::DirectUploadResponse.new(filename: 'sul.svg', signed_id: '9999999')])
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_return(1234)
    end

    it 'initiates a DepositStatusJob' do
      described_class.perform_now(work_version)
      expect(SdrClient::Deposit::UploadFiles).to have_received(:upload)
      expect(DepositStatusJob).to have_received(:perform_later).with(object: work_version, job_id: 1234)
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_raise('Deposit failed.')
    end

    it 'notifies' do
      described_class.perform_now(work_version)
      expect(SdrClient::Deposit::UploadFiles).to have_received(:upload)
      expect(DepositStatusJob).not_to have_received(:perform_later)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
