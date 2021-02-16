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
    let(:work) { create(:work) }

    it 'is successful' do
      get "/works/#{work.id}/validate?work[citation]=foo"
      expect(response).to be_successful
    end
  end
end
