# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve a file from preservation' do
  let(:work_version) { create(:work_version) }
  let(:attached_file) { create(:attached_file, :with_file, work_version:) }
  let(:body) { 'All happy families are alike, but every unhappy family is unhappy in its own way' }

  before do
    work_version.work.update(druid: 'druid:bb111bb1111')
  end

  context 'with authenticated, authorized user' do
    before do
      sign_in(work_version.work.owner)

      stub_request(:get, 'https://preservation-catalog-stage-01.stanford.edu/v1/objects/druid:bb111bb1111/file?category=content&filepath=sul.svg&version=1')
        .with(
          headers: {
            'Authorization' => 'Bearer mint-token-with-target-preservation-catalog-rake-generate-token'
          }
        )
        .to_return(status: 200, body:, headers: {})
    end

    it 'gets the expected file' do
      get "/preservation/#{attached_file.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq body
    end
  end

  context 'with authenticated, unauthorized user' do
    let(:unauthorized_user) { create(:user) }

    before do
      sign_in(unauthorized_user)
    end

    it 'redirects to the root URL' do
      get "/preservation/#{attached_file.id}"
      expect(response).to redirect_to(root_path)
    end
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects to the login URL' do
      get "/preservation/#{attached_file.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
