# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Works requests' do
  let(:work) { create(:work) }
  let(:collection) { create(:collection) }

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id/works/new to login URL' do
      post "/works/#{work.id}/review"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an authenticated user' do
    let(:user) { collection.reviewers.first }
    let(:collection) { create(:collection, :with_reviewers) }
    let(:work) { create(:work, :pending_approval, collection: collection) }

    before do
      sign_in user
      allow(DepositJob).to receive(:perform_later)
    end

    describe 'accepting a deposit' do
      it 'does the deposit' do
        post "/works/#{work.id}/review", params: { state: 'approve' }
        expect(response).to redirect_to(dashboard_path)
        expect(DepositJob).to have_received(:perform_later)
      end
    end

    describe 'rejecting a deposit' do
      it 'returns the deposit and records the reason' do
        post "/works/#{work.id}/review", params: { state: 'return', reason: 'Add more stuff' }
        expect(response).to redirect_to(dashboard_path)
        expect(DepositJob).not_to have_received(:perform_later)
        expect(work.reload).to be_first_draft
        expect(work.events.last.description).to eq 'Add more stuff'
      end
    end
  end
end
