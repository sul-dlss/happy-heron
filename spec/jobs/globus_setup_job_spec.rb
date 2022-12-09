# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobusSetupJob do
  let(:user) { create(:user) }
  let(:work_version) { create(:work_version, work:) }
  let(:collection_version) do
    create(:collection_version_with_collection, managed_by: [user])
  end
  let(:work) { create(:work, owner: user, collection: collection_version.collection) }

  before { work.update(head: work_version) }

  context 'when the user is known to globus' do
    before do
      allow(GlobusClient).to receive(:user_exists?).and_return(true)
      allow(GlobusClient).to receive(:mkdir).and_return(true)
    end

    context 'when the work does not yet have an endpoint created' do
      context 'when in first_draft state' do
        before { work_version.update(state: 'first_draft') }

        it 'creates the globus endpoint, sends the email but does not transition state' do
          expect(work_version.state).to eq 'first_draft'
          described_class.perform_now(work_version)
          expect(GlobusClient).to have_received(:mkdir)
          expect(work_version.state).to eq 'first_draft'
          # TODO: verify email got sent
        end
      end

      context 'when in globus_setup_first_draft state' do
        before { work_version.update(state: 'globus_setup_first_draft') }

        it 'creates the globus endpoint, sends the email and transitions back to first_draft state' do
          described_class.perform_now(work_version)
          expect(GlobusClient).to have_received(:mkdir)
          expect(work_version.state).to eq 'first_draft'
          # TODO: verify email got sent
        end
      end
    end

    context 'when the work already has an endpoint created' do
      before do
        work_version.update(globus_endpoint: '/uploads/something')
        work_version.update(state: 'first_draft')
      end

      it 'does nothing' do
        described_class.perform_now(work_version)
        expect(GlobusClient).not_to have_received(:mkdir)
        expect(work_version.state).to eq 'first_draft'
        # TODO: verify email did not got sent
      end
    end
  end

  context 'when the user is not known to globus' do
    before do
      allow(GlobusClient).to receive(:user_exists?).and_return(false)
      allow(GlobusClient).to receive(:mkdir)
    end

    context 'when the work is not in the globus setup draft state' do
      before { work_version.update(state: 'first_draft') }

      it 'transitions into the globus_setup_first_draft state' do
        described_class.perform_now(work_version)
        expect(GlobusClient).not_to have_received(:mkdir)
        expect(work_version.state).to eq 'globus_setup_first_draft'
      end
    end

    context 'when work is already in a globus setup draft state' do
      before { work_version.update(state: 'globus_setup_first_draft') }

      it 'does nothing' do
        described_class.perform_now(work_version)
        expect(GlobusClient).not_to have_received(:mkdir)
        expect(work_version.state).to eq 'globus_setup_first_draft'
      end
    end
  end
end
