# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retrieve a file from preservation', type: :request do
  describe 'GET' do
    let(:work_version) { create(:work_version) }
    let(:attached_file) { create(:attached_file, :with_file, work_version:) }
    let(:body) { 'All happy families are alike, but every unhappy family is unhappy in its own way' }

    before do
      work_version.work.update(druid: 'druid:bb111bb1111')
      sign_in(work_version.work.owner)

      stub_request(:get, 'https://preservation-catalog-stage-01.stanford.edu/v1/objects/druid:bb111bb1111/file?category=content&filepath=sul.svg&version=1')
        .with(
          headers: {
            'Authorization' => 'Bearer mint-token-with-target-preservation-catalog-rake-generate-token'
          }
        )
        .to_return(status: 200, body:, headers: {})
    end

    it 'is successful' do
      get "/preservation/#{attached_file.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq body
    end
  end
end
