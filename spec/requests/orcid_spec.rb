# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orcid', type: :request do
  describe 'GET /search' do
    context 'when search successful' do
      before do
        allow(OrcidService).to receive(:lookup).and_return(Dry::Monads::Result::Success.new(%w[Wilford Brimley]))
      end

      it 'returns the data' do
        get '/orcid?id=0000-0003-1527-0030'

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('{"orcid":"0000-0003-1527-0030","first_name":"Wilford","last_name":"Brimley"}')
        expect(OrcidService).to have_received(:lookup).with(orcid: '0000-0003-1527-0030')
      end
    end

    context 'when search unsuccessful' do
      before do
        allow(OrcidService).to receive(:lookup).and_return(Dry::Monads::Result::Failure.new(404))
      end

      it 'returns status' do
        get '/orcid?id=0000-0003-1527-0030'

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
