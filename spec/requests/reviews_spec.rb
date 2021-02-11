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
    let(:user) { collection.reviewed_by.first }
    let(:collection) { create(:collection, :with_reviewers) }
    let(:work) { create(:work, collection: collection) }
    let(:work_version) { create(:work_version, :pending_approval, work: work) }

    before do
      work.update(head: work_version)
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
        expect do
          post "/works/#{work.id}/review", params: { state: 'reject', reason: 'Add more stuff' }
        end.to change(Event, :count).by(1)
        expect(response).to redirect_to(dashboard_path)
        expect(DepositJob).not_to have_received(:perform_later)

        expect(work_version.reload).to be_rejected
        expect(work.reload.events.last.description).to eq 'Add more stuff'
      end
    end
  end
end
