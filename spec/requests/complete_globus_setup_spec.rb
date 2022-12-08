# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User indicates globus setup is complete' do
  let(:user) { create(:user) }
  let(:work_version) { create(:work_version, work:) }
  let(:collection_version) do
    create(:collection_version_with_collection, managed_by: [user])
  end
  let(:work) { create(:work, owner: user, collection: collection_version.collection) }

  before do
    work.update(head: work_version)
    sign_in user, groups: ['dlss:hydrus-app-administrators']
    allow(Settings).to receive(:globus_upload).and_return(true)
    allow(GlobusSetupJob).to receive(:perform_later)
  end

  context 'when the user has not yet completed their globus setup' do
    before { allow(GlobusClient).to receive(:user_exists?).and_return(false) }

    it 'does does not start the GlobusSetupJob' do
      get complete_globus_setup_work_path(work)
      expect(GlobusSetupJob).not_to have_received(:perform_later)

      follow_redirect!
      # Flash message
      expect(response.body).to include 'You have not completed your Globus setup yet'
    end
  end

  context 'when the user has completed their globus setup' do
    before { allow(GlobusClient).to receive(:user_exists?).and_return(true) }

    it 'starts the GlobusSetupJob' do
      get complete_globus_setup_work_path(work)
      expect(GlobusSetupJob).to have_received(:perform_later)

      follow_redirect!
      # Flash message
      expect(response.body).to include 'Please check for email for further instructions on how to proceed'
    end
  end
end
