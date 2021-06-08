# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Autocomplete Controller' do
  let(:headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
    }
  end

  context 'when lookup is successful' do
    let(:status) { 200 }
    let(:lookup_resp_body) do
      <<~JSON
        [
          {
            "uri": "http://id.worldcat.org/fast/170115",
            "id": "170115",
            "label": "McCrae, John, 1872-1918"
          },
          {
            "uri": "http://id.worldcat.org/fast/212322",
            "id": "212322",
            "label": "McRae family"
          },
          {
            "uri": "http://id.worldcat.org/fast/127989",
            "id": "127989",
            "label": "McRae, Carmen"
          },
          {
            "uri": "http://id.worldcat.org/fast/1742722",
            "id": "1742722",
            "label": "McRae, Logan (Fictitious character)"
          }
        ]
      JSON
    end
    let(:query) { 'mcrae' }

    it 'returns status 200 and the JSON from the lookup server' do
      url = "#{Settings.autocomplete_lookup.url}?maxRecords=#{Settings.autocomplete_lookup.max_records}&q=#{query}"
      stub_request(:get, url).with(headers: headers).to_return(status: status, body: lookup_resp_body, headers: {})
      get '/autocomplete', params: { q: query }
      expect(response.status).to eq 200
      expect(response.body).to eq lookup_resp_body
    end

    context 'with no content' do
      before do
        url = "#{Settings.autocomplete_lookup.url}?maxRecords=#{Settings.autocomplete_lookup.max_records}&q=#{query}"
        stub_request(:get, url).with(headers: headers).to_return(status: 204, body: '', headers: {})
        get '/autocomplete', params: { q: query }
      end

      it 'returns status 204 and empty body' do
        expect(response.status).to eq 204
        expect(response.body).to eq ''
      end
    end

    context 'with changed lookup params' do
      let(:max_records) { 18 }
      let(:diff_query) { 'mcrae' }

      before do
        allow(Settings.autocomplete_lookup).to receive(:max_records).and_return(max_records)
        stub_request(:get, "#{Settings.autocomplete_lookup.url}?maxRecords=#{max_records}&q=#{diff_query}")
          .with(headers: headers)
          .to_return(status: status, body: lookup_resp_body, headers: {})
      end

      it 'sends params q=query and maxRecords=Settings.autocomplete_lookup.max_records' do
        get '/autocomplete', params: { q: diff_query }
      end
    end
  end

  context 'when error is received from the lookup server' do
    let(:error_status) { [404, 'some error message'] }
    let(:query) { 'broken' }
    let(:resp_body) do
      <<~JSON
        {"errors":"Something is wrong"}
      JSON
    end

    before do
      url = "#{Settings.autocomplete_lookup.url}?maxRecords=#{Settings.autocomplete_lookup.max_records}&q=#{query}"
      stub_request(:get, url)
        .with(headers: headers)
        .to_return(status: error_status, body: resp_body, headers: {})
      allow(Rails.logger).to receive(:warn).with("Autocomplete results for #{query} returned 404")
    end

    it 'returns status 500 and an empty body' do
      get '/autocomplete', params: { q: query }
      expect(response.status).to eq 500
      expect(response.body).to eq ''
    end

    it 'logs a warning' do
      get '/autocomplete', params: { q: query }
      expect(Rails.logger).to have_received(:warn).with("Autocomplete results for #{query} returned 404")
    end
  end
end
