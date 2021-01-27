# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositStatusJob do
  include Dry::Monads[:result]

  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:result) { Success() }
  let(:job_id) { 1234 }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(result)
    allow(SdrClient::BackgroundJobResults).to receive(:show).and_return(background_result)
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the job is successful' do
    let(:background_result) { { status: 'complete', output: { druid: druid } } }

    context 'with a work' do
      context 'with a citation' do
        let(:work) do
          build(:work, :depositing,
                citation: "Zappa, F. (2013) #{Work::LINK_TEXT}", collection: collection,
                depositor: collection.managers.first)
        end
        let(:collection) { build(:collection, :with_managers) }

        it 'updates the work' do
          expect do
            described_class.perform_now(object: work, job_id: job_id)
          end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'collection_activity', 'deliver_now',
            { params: {
              user: collection.managers.last,
              depositor: work.depositor,
              collection: collection
            }, args: [] }
          )

          expect(work.druid).to eq druid
          expect(work.citation).to eq 'Zappa, F. (2013) https://purl.stanford.edu/bc123df4567'
          expect(work.state_name).to eq :deposited
        end
      end

      context 'without a citation' do
        let(:work) { build(:work, :depositing, citation: nil) }

        it 'adds a druid and transitions to deposited state' do
          described_class.perform_now(object: work, job_id: job_id)
          expect(work.druid).to eq druid
          expect(work.state_name).to eq :deposited
        end
      end
    end

    context 'with a collection' do
      let(:collection) { build(:collection, :depositing) }

      it 'adds a druid and transitions to deposited state' do
        described_class.perform_now(object: collection, job_id: job_id)
        expect(collection.druid).to eq druid
        expect(collection.state_name).to eq :deposited
      end
    end
  end

  context 'when the job is not successful' do
    let(:background_result) { { status: 'complete', output: { errors: [{ title: 'something went wrong' }] } } }
    let(:work) { build(:work, state: 'depositing') }

    it 'notifies' do
      described_class.perform_now(object: work, job_id: job_id)
      expect(work.druid).to be_nil
      expect(work.state_name).to eq :depositing
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'when the job is not completed' do
    let(:background_result) { { status: 'incomplete' } }
    let(:work) { build(:work, state: 'depositing') }

    it 'raises a custom exception (so it can be ignored by Honeybadger)' do
      expect { described_class.perform_now(object: work, job_id: job_id) }.to raise_error(
        TryAgainLater, 'No result yet for job 1234'
      )
    end
  end
end
