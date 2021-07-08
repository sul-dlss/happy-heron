# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountService do
  let(:instance) { described_class.new }

  describe '#fetch' do
    subject(:fetch) { instance.fetch('jcoyne85') }

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

      stub_request(:get, 'https://accountws-uat.stanford.edu/accounts/jcoyne85')
        .to_return(status: 200, body: body, headers: {})
    end

    it 'returns data' do
      expect(fetch).to eq(
        'name' => 'Coyne, Justin Michael',
        'description' => 'Digital Library Systems and Services, Digital Library Software Engineer ' \
                         '- Web & Infrastructure'
      )
    end
  end
end
