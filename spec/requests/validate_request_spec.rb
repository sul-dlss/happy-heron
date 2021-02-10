# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validates', type: :request do
  context 'when the work is new' do
    let(:collection) { create(:collection) }

    it 'is successful' do
      get "/collections/#{collection.id}/validate?work[citation]=foo"
      expect(response).to be_successful
    end
  end

  context 'when the work is persisted' do
    let(:work_version) { create(:work_version) }
    let(:work) { work_version.work }

    before do
      work.update(head: work_version)
    end

    it 'is successful' do
      get "/works/#{work_version.work.id}/validate?work[citation]=foo&work[keywords_attributes][0][label]=key"
      expect(response).to be_successful
      expect(work_version.keywords).to be_empty
    end
  end
end
