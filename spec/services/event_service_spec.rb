# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventService do
  let(:depositor) { create(:user) }

  before do
    allow(WorkUpdatesChannel).to receive(:broadcast_to)
  end

  describe '.reject' do
    let(:work) { create(:work, :pending_approval, depositor: depositor) }

    it 'rejects the work' do
      expect { described_class.reject(work: work, user: depositor, description: 'bad') }
        .to change(work, :state)
        .from('pending_approval').to('first_draft')
    end

    it 'creates an event' do
      expect { described_class.reject(work: work, user: depositor, description: 'bad') }
        .to change(Event, :count)
        .by(1)
    end

    it 'broadcasts the state change' do
      described_class.reject(work: work, user: depositor, description: 'bad')
      expect(WorkUpdatesChannel).to have_received(:broadcast_to).with(work, state: 'Draft - Not deposited').once
    end
  end

  describe '.begin_deposit' do
    let(:work) { create(:work, :first_draft, depositor: depositor) }

    it 'begins depositing the work' do
      expect { described_class.begin_deposit(work: work, user: depositor) }
        .to change(work, :state)
        .from('first_draft').to('depositing')
    end

    it 'creates an event' do
      expect { described_class.begin_deposit(work: work, user: depositor) }
        .to change(Event, :count)
        .by(1)
    end

    it 'broadcasts the state change' do
      described_class.begin_deposit(work: work, user: depositor)
      expect(WorkUpdatesChannel).to have_received(:broadcast_to)
        .with(work, state: 'Deposit in progress <span class="fas fa-spinner fa-pulse"></span>').once
    end
  end

  describe '.deposit_complete' do
    let(:work) { create(:work, :depositing, depositor: depositor, druid: 'druid:bk875mg9867') }

    it 'completes depositing the work' do
      expect { described_class.deposit_complete(work: work) }
        .to change(work, :state)
        .from('depositing').to('deposited')
    end

    it 'creates an event' do
      expect { described_class.deposit_complete(work: work) }
        .to change(Event, :count)
        .by(1)
    end

    it 'broadcasts the state change' do
      described_class.deposit_complete(work: work)
      expect(WorkUpdatesChannel).to have_received(:broadcast_to)
        .with(
          work,
          state: 'Deposited',
          purl: '<a href="https://purl.stanford.edu/bk875mg9867">https://purl.stanford.edu/bk875mg9867</a>'
        )
        .once
    end
  end

  describe '.submit_for_review' do
    let(:work) { create(:work, :first_draft, depositor: depositor) }

    it 'submits the work for review' do
      expect { described_class.submit_for_review(work: work, user: depositor) }
        .to change(work, :state)
        .from('first_draft').to('pending_approval')
    end

    it 'creates an event' do
      expect { described_class.submit_for_review(work: work, user: depositor) }
        .to change(Event, :count)
        .by(1)
    end

    it 'broadcasts the state change' do
      described_class.submit_for_review(work: work, user: depositor)
      expect(WorkUpdatesChannel).to have_received(:broadcast_to)
        .with(work, state: 'Pending approval - Not deposited')
        .once
    end
  end
end
