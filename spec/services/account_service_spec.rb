# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService do
  let(:instance) { described_class.new }

  describe '#fetch' do
    subject(:fetch) { instance.fetch(sunetid) }

    let(:body) do
      <<~JSON
        {
          "name":"Coyne, Justin Michael",
          "description":"Digital Library Systems and Services, Digital Library Software Engineer - Web \\u0026 Infrastructure",
          "otherStuff":"Is ignored"
        }
      JSON
    end

    before do
      allow(File).to receive(:read).with('/etc/pki/tls/certs/sul-h2-qa.stanford.edu.pem').and_return('foo')
      allow(OpenSSL::PKey).to receive(:read).and_return('bar')
      allow(OpenSSL::X509::Certificate).to receive(:new).and_return('baz')
    end

    context 'with a string that requires no encoding' do
      let(:sunetid) { 'jcoyne85' }

      before do
        stub_request(:get, 'https://accountws-uat.stanford.edu/accounts/jcoyne85')
          .to_return(status: 200, body:, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns data' do
        expect(fetch).to eq(
          'name' => 'Coyne, Justin Michael',
          'description' => 'Digital Library Systems and Services, Digital Library Software Engineer ' \
                           '- Web & Infrastructure'
        )
      end
    end

    context 'with a string that has a space' do
      let(:sunetid) { 'Justin Coyne' }

      before do
        stub_request(:get, 'https://accountws-uat.stanford.edu/accounts/Justin%20Coyne')
          .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'encodes the space so that it is a valid URI' do
        expect(fetch).to eq({})
      end
    end

    context 'when API returns a 404 response' do
      let(:body) do
        <<~JSON
          {
            "status":404,
            "message":"Account [foobarbaz] not found",
            "url":"https://accountws-uat.stanford.edu/accounts/foobarbaz"
          }
        JSON
      end
      let(:sunetid) { 'foobarbaz' }

      before do
        stub_request(:get, 'https://accountws-uat.stanford.edu/accounts/foobarbaz')
          .to_return(status: 404, body:, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns an empty response' do
        expect(fetch).to eq({})
      end
    end

    context 'when API returns a 500 response' do
      let(:body) do
        <<~JSON
          {
            "status":500,
            "message":"Internal Error - Failed to find account due to Could not open JPA EntityManager for transaction; nested exception is org.hibernate.exception.JDBCConnectionException: Could not open connection",
            "url":"https://accountws-uat.stanford.edu/accounts/foobarbaz"
          }
        JSON
      end
      let(:sunetid) { 'foobarbaz' }

      before do
        stub_request(:get, 'https://accountws-uat.stanford.edu/accounts/foobarbaz')
          .to_return(status: 500, body:, headers: { 'Content-Type' => 'application/json' })
      end

      it 'retries up to five times' do
        expect(fetch).to be_nil
      end
    end
  end
end
