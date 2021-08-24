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
  let(:work) { build(:work, collection: collection, assign_doi: false) }
  let(:work_version) do
    build(:work_version, id: 8, work: work, attached_files: [attached_file])
  end
  let(:collection) { build(:collection, druid: 'druid:bc123df4567', doi_option: 'depositor-selects') }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(Success())
    allow(SdrClient::Connection).to receive(:new).and_return(conn)
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
    end

    context 'when the deposit wants a doi' do
      let(:work) { build(:work, collection: collection, assign_doi: true) }

      it 'calls CreateResource.run with true for the assign_doi param' do
        described_class.perform_now(work_version)
        expect(SdrClient::Deposit::CreateResource).to have_received(:run)
          .with(a_hash_including(accession: true, assign_doi: true))
      end
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::Deposit::UploadFiles).to receive(:upload)
        .and_return([SdrClient::Deposit::Files::DirectUploadResponse.new(filename: 'sul.svg', signed_id: '9999999')])
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_raise('Deposit failed.')
    end

    it 'notifies' do
      expect { described_class.perform_now(work_version) }.to raise_error(RuntimeError, 'Deposit failed.')
      expect(SdrClient::Deposit::UploadFiles).to have_received(:upload)
    end
  end
end
