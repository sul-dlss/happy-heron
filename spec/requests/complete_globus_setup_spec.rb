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
    allow(GlobusSetupJob).to receive(:perform_later)
    stub_request(:get, /auth.globus.org/)
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization' => 'Bearer',
          'User-Agent' => 'Faraday v2.7.2'
        }
      )
      .to_return(status: 200)
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
