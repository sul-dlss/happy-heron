# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositStatusJob do
  include Dry::Monads[:result]

  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:work) { build(:work) }
  let(:result) { Success() }
  let(:job_id) { 1234 }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(result)
    allow(SdrClient::BackgroundJobResults).to receive(:show).and_return(background_result)
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the job is successful' do
    let(:background_result) { { status: 'complete', output: { druid: druid } } }

    it 'updates the work' do
      described_class.perform_now(work: work, job_id: job_id)
      expect(work.druid).to eq druid
      expect(work.state_name).to eq :deposited
    end
  end

  context 'when the job is not successful' do
    let(:background_result) { { status: 'complete', output: { errors: [{ title: 'something went wrong' }] } } }

    it 'notifies' do
      described_class.perform_now(work: work, job_id: job_id)
      expect(work.druid).to be_nil
      expect(work.state_name).to eq :first_draft
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'when the job is not completed' do
    let(:background_result) { { status: 'incomplete' } }

    it 'raises' do
      expect { described_class.perform_now(work: work, job_id: job_id) }.to raise_error('No result yet for job 1234')
    end
  end
end
