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
  let(:expected_params) do
    result = ''
    {
      query: query,
      queryIndex: Settings.autocomplete_lookup.query_index,
      queryReturn: URI::DEFAULT_PARSER.escape(Settings.autocomplete_lookup.query_return),
      rows: Settings.autocomplete_lookup.num_records,
      suggest: 'autoSubject'
    }.each_pair { |k, v| result += "#{k}=#{v}&" }
    result.chop
  end

  context 'when lookup is successful' do
    let(:status) { 200 }
    let(:query) { 'bro' }
    let(:lookup_resp_body) do
      <<~JSON
        {
          "responseHeader":{
            "status":0,
            "QTime":2,
            "params":{
              "q":"suggestall:bro",
              "fl":"suggestall"}},
          "response":{"numFound":18884,"start":0,"docs":
            [
              {
                "idroot":"fst01204289",
                "type":"alt",
                "auth":"France",
                "suggestall":[
                  "Bro-C'hall"]},
              {
                "idroot":"fst00839671",
                "type":"auth",
                "auth":"Brothers and sisters",
                "suggestall":[
                  "Brothers and sisters"]},
              {
                "idroot":"fst00839671",
                "type":"alt",
                "auth":"Brothers and sisters",
                "suggestall":[
                  "Sisters and brothers"]},
              {
                "idroot":"fst01146714",
                "type":"auth",
                "auth":"Television broadcasting",
                "suggestall":[
                  "Television broadcasting"]},
              {
                "idroot":"fst00839665",
                "type":"auth",
                "auth":"Brothers",
                "suggestall":[
                  "Brothers"]},
              {
                "idroot":"fst01098312",
                "type":"alt",
                "auth":"Rivers",
                "suggestall":[
                  "Brooks"]},
              {
                "idroot":"fst00881986",
                "type":"alt",
                "auth":"Cowboys",
                "suggestall":[
                  "Bronco busters"]},
              {
                "idroot":"fst00881986",
                "type":"alt",
                "auth":"Cowboys",
                "suggestall":[
                  "Broncobusters"]},
              {
                "idroot":"fst00972696",
                "type":"alt",
                "auth":"Information services",
                "suggestall":[
                  "Information brokers"]},
              {
                "idroot":"fst01312516",
                "type":"auth",
                "auth":"New York (State)--New York--Brooklyn",
                "suggestall":[
                  "New York (State)--New York--Brooklyn"]},
              {
                "idroot":"fst01312516",
                "type":"alt",
                "auth":"New York (State)--New York--Brooklyn",
                "suggestall":[
                  "New York (N.Y.). Brooklyn"]},
              {
                "idroot":"fst01312516",
                "type":"alt",
                "auth":"New York (State)--New York--Brooklyn",
                "suggestall":[
                  "New York (State)--Brooklyn"]},
              {
                "idroot":"fst01312516",
                "type":"alt",
                "auth":"New York (State)--New York--Brooklyn",
                "suggestall":[
                  "New York (State)--New  York--Broklino"]},
              {
                "idroot":"fst01312516",
                "type":"alt",
                "auth":"New York (State)--New York--Brooklyn",
                "suggestall":[
                  "New York (State)--New York--Brouklin"]},
              {
                "idroot":"fst01087224",
                "type":"auth",
                "auth":"Radio broadcasting",
                "suggestall":[
                  "Radio broadcasting"]},
              {
                "idroot":"fst00839252",
                "type":"auth",
                "auth":"Broadsides",
                "suggestall":[
                  "Broadsides"]},
              {
                "idroot":"fst00839252",
                "type":"alt",
                "auth":"Broadsides",
                "suggestall":[
                  "Broadsheets"]},
              {
                "idroot":"fst00839252",
                "type":"alt",
                "auth":"Broadsides",
                "suggestall":[
                  "Broadside ballads"]},
              {
                "idroot":"fst01109473",
                "type":"alt",
                "auth":"Sculptors",
                "suggestall":[
                  "Bronze sculptors"]},
              {
                "idroot":"fst00839439",
                "type":"auth",
                "auth":"Bronze age",
                "suggestall":[
                  "Bronze age"]
              }
            ]
          }
        }
      JSON
    end

    # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
    let(:suggestions) do
      [
        'France' => 'http://id.worldcat.org/fast/1204289/', # suggestall Bro-C'hall
        'Brothers and sisters' => 'http://id.worldcat.org/fast/839671/',
        # 'Sisters and brothers' => # http://id.worldcat.org/fast/839671 alt
        'Television broadcasting' => 'http://id.worldcat.org/fast/1146714/',
        'Brothers' => 'http://id.worldcat.org/fast/839665/',
        'Rivers' => 'http://id.worldcat.org/fast/1098312/', # suggestall: Brooks
        'Cowboys' => 'http://id.worldcat.org/fast/0881986/', # suggestall: Bronco busters
        # 'Broncobusters', # http://id.worldcat.org/fast/881986 also
        'Information services' => 'http://id.worldcat.org/fast/972696/', # suggestall: Information brokers
        'New York (State)--New York--Brooklyn' => 'http://id.worldcat.org/fast/1312516/',
        # 'New York (N.Y.). Brooklyn', # http://id.worldcat.org/fast/1312516 also
        # 'New York (State)--Brooklyn', # http://id.worldcat.org/fast/1312516 also
        # 'New York (State)--New  York--Broklino', # http://id.worldcat.org/fast/1312516 also
        # 'New York (State)--New York--Brouklin', # http://id.worldcat.org/fast/1312516 also
        'Radio broadcasting' => 'http://id.worldcat.org/fast/1087224/',
        'Broadsides' => 'http://id.worldcat.org/fast/839252/'
      ]
    end

    before do
      url = "#{Settings.autocomplete_lookup.url}?#{expected_params}"
      stub_request(:get, url).with(headers: headers).to_return(status: status, body: lookup_resp_body, headers: {})
    end

    it 'returns status 200' do
      get '/autocomplete', params: { q: query }
      expect(response.status).to eq 200
    end

    # rubocop:disable Layout/LineLength
    it 'returns html <li> item for each suggestion' do
      get '/autocomplete', params: { q: query }

      li_prefix = '<li class="list-group-item" role="option"'
      suggestions.each do |suggestion|
        actual_suggestion = suggestion.keys.first
        uri = suggestion.values.first
        li_element_html = "#{li_prefix} data-autocomplete-value=\"#{uri}\" data-autocomplete-label=\"#{actual_suggestion}\">#{ERB::Util.html_escape(actual_suggestion)}</li>"
        expect(response.body).to include(li_element_html)
      end
    end
    # rubocop:enable Layout/LineLength

    context 'with no content' do
      before do
        url = "#{Settings.autocomplete_lookup.url}?#{expected_params}"
        stub_request(:get, url).with(headers: headers).to_return(status: 204, body: '', headers: {})
        get '/autocomplete', params: { q: query }
      end

      it 'returns status 204 and empty body' do
        expect(response.status).to eq 204
        expect(response.body).to eq ''
      end
    end

    context 'with changed lookup params' do
      let(:diff_query) { 'mcrae' }
      let(:query_index) { 'suggest50' }
      let(:query_return) { 'suggestall,type,auth' }
      let(:num_records) { 5 }
      let(:new_expected_params) do
        result = ''
        {
          query: diff_query,
          queryIndex: query_index,
          queryReturn: query_return,
          rows: num_records,
          suggest: 'autoSubject'
        }.each_pair { |k, v| result += "#{k}=#{v}&" }
        result.chop
      end
      let(:expected_url) { "#{Settings.autocomplete_lookup.url}?#{new_expected_params}" }

      before do
        allow(Settings.autocomplete_lookup).to receive(:query_index).and_return(query_index)
        allow(Settings.autocomplete_lookup).to receive(:query_return).and_return(query_return)
        allow(Settings.autocomplete_lookup).to receive(:num_records).and_return(num_records)
        stub_request(:get, "#{Settings.autocomplete_lookup.url}?#{new_expected_params}")
          .with(headers: headers)
          .to_return(status: status, body: lookup_resp_body, headers: {})
      end

      it 'sends expected params to lookup url' do
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
      url = "#{Settings.autocomplete_lookup.url}?#{expected_params}"
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
