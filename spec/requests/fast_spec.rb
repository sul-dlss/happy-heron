# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fast Controller' do
  let(:headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
    }
  end
  let(:other_params) do
    '&rows=20&sort=usage+desc&queryIndex=suggestall&queryReturn=idroot,suggestall,tag&suggest=autoSubject'
  end

  context 'when lookup is successful' do
    let(:lookup_resp_body) do
      {
        response: {
          docs: [
            {
              idroot: [
                'fst01144120'
              ],
              tag: 150,
              suggestall: [
                'Tea'
              ]
            },
            {
              idroot: [
                'fst01762507'
              ],
              tag: 150,
              suggestall: [
                'Tea Party movement'
              ]
            },
            {
              idroot: [
                'fst01144165'
              ],
              tag: 150,
              suggestall: [
                'Tea making paraphernalia'
              ]
            },
            {
              idroot: [
                'fst01144178'
              ],
              tag: 150,
              suggestall: [
                'Tea tax (American colonies)'
              ]
            },
            {
              idroot: [
                'fst01144179'
              ],
              tag: 150,
              suggestall: [
                'Tea trade'
              ]
            },
            {
              idroot: [
                'fst01144131'
              ],
              tag: 150,
              suggestall: [
                'Tea--Health aspects'
              ]
            },
            {
              idroot: [
                'fst01144144'
              ],
              tag: 150,
              suggestall: [
                'Tea--Social aspects'
              ]
            },
            {
              idroot: [
                'fst01144148'
              ],
              tag: 150,
              suggestall: [
                'Tea--Therapeutic use'
              ]
            },
            {
              idroot: [
                'fst01144712'
              ],
              tag: 150,
              suggestall: [
                'Tearooms'
              ]
            },
            {
              idroot: [
                'fst00537796'
              ],
              tag: 110,
              suggestall: [
                'East India Company'
              ]
            }
          ]
        }
      }.to_json
    end

    # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
    let(:suggestions) do
      [
        { 'Tea' => 'http://id.worldcat.org/fast/1144120/::topic' },
        { 'Tea Party movement' => 'http://id.worldcat.org/fast/1762507/::topic' },
        { 'Tea making paraphernalia' => 'http://id.worldcat.org/fast/1144165/::topic' },
        { 'Tea tax (American colonies)' => 'http://id.worldcat.org/fast/1144178/::topic' },
        { 'Tea trade' => 'http://id.worldcat.org/fast/1144179/::topic' },
        { 'Tea--Health aspects' => 'http://id.worldcat.org/fast/1144131/::topic' },
        { 'Tea--Social aspects' => 'http://id.worldcat.org/fast/1144144/::topic' },
        { 'Tea--Therapeutic use' => 'http://id.worldcat.org/fast/1144148/::topic' },
        { 'Tearooms' => 'http://id.worldcat.org/fast/1144712/::topic' },
        { 'East India Company' => 'http://id.worldcat.org/fast/537796/::organization' }
      ]
    end

    before do
      url = "#{Settings.autocomplete_lookup.url}?query=tea#{other_params}"
      stub_request(:get, url).with(headers:).to_return(status: 200, body: lookup_resp_body, headers: {})
    end

    it 'returns status 200 and html with suggestions' do
      get '/fast', params: { q: 'tea' }
      expect(response).to have_http_status :ok

      suggestions.each do |suggestion|
        actual_suggestion = suggestion.keys.first
        uri = suggestion.values.first
        li_element_html = '<li class="list-group-item" role="option" ' \
                          "data-autocomplete-value=\"#{uri}\" data-autocomplete-label=\"#{actual_suggestion}\">" \
                          "#{ERB::Util.html_escape(actual_suggestion)}</li>"
        expect(response.body).to include(li_element_html)
      end
    end
  end

  context 'when error is received from the lookup server' do
    before do
      url = "#{Settings.autocomplete_lookup.url}?query=tea#{other_params}"
      stub_request(:get, url)
        .with(headers:)
        .to_return(status: [404, 'some error message'], body: '', headers: {})
      allow(Rails.logger).to receive(:warn)
      allow(Honeybadger).to receive(:notify)
    end

    it 'returns status 500 and an empty body' do
      get '/fast', params: { q: 'tea' }
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to eq ''
      expect(Rails.logger).to have_received(:warn).with('Autocomplete results for tea returned HTTP 404')
      expect(Honeybadger).to have_received(:notify)
        .with('FAST API Error', context: hash_including(:params, :response)).once
    end
  end

  context 'when malformed JSON is received from the lookup server' do
    let(:body) do
      <<~MALFORMED_JSON
        Status: 400
        Reason: Bad Request
      MALFORMED_JSON
    end

    before do
      url = "#{Settings.autocomplete_lookup.url}?query=tea#{other_params}"
      stub_request(:get, url)
        .with(headers:)
        .to_return(status: 200, body:, headers: {})
      allow(Rails.logger).to receive(:warn)
      allow(Honeybadger).to receive(:notify)
    end

    it 'returns status 500 and an empty body' do
      get '/fast', params: { q: 'tea' }
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to eq ''
      expect(Rails.logger).to have_received(:warn)
        .with("Autocomplete results for tea returned unexpected response 'Status: 400\n" \
              "Reason: Bad Request\n" \
              "'")
      expect(Honeybadger).to have_received(:notify)
        .with('Unexpected response from FAST API', context: hash_including(:params, :response, :exception)).once
    end
  end
end
