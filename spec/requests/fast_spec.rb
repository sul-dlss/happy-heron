# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Fast Controller" do
  let(:headers) do
    {
      "Accept" => "application/xml",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Stanford Self-Deposit (Happy Heron)"
    }
  end

  let(:other_params) { "&rows=20&start=0&version=2.2&indent=on&fl=id,fullphrase,type&sort=usage+desc" }

  context "when lookup is successful without wildcard" do
    let(:lookup_resp_body) do
      <<~XML
                <?xml version="1.0" encoding="UTF-8"?>
                <response>
        #{"        "}
                <result name="response" numFound="299" start="0">
                  <doc>
                    <str name="id">fst00537796</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">East India Company</str></doc>
                  <doc>
                    <str name="id">fst01144120</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea</str></doc>
                  <doc>
                    <str name="id">fst01144179</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea trade</str></doc>
                  <doc>
                    <str name="id">fst00981955</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Japanese tea ceremony</str></doc>
                  <doc>
                    <str name="id">fst01144712</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tearooms</str></doc>
                  <doc>
                    <str name="id">fst00981970</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Japanese tea ceremony--Utensils</str></doc>
                  <doc>
                    <str name="id">fst00800074</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Afternoon teas</str></doc>
                  <doc>
                    <str name="id">fst01144148</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea--Therapeutic use</str></doc>
                  <doc>
                    <str name="id">fst00955318</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Herbal teas</str></doc>
                  <doc>
                    <str name="id">fst01802011</str>
                    <str name="type">event</str>
                    <str name="fullphrase">Boston Tea Party (Boston, Massachusetts : 1773)</str></doc>
                  <doc>
                    <str name="id">fst01753202</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Cooking (Tea)</str></doc>
                  <doc>
                    <str name="id">fst01144165</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea making paraphernalia</str></doc>
                  <doc>
                    <str name="id">fst01762507</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea Party movement</str></doc>
                  <doc>
                    <str name="id">fst01144178</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea tax (American colonies)</str></doc>
                  <doc>
                    <str name="id">fst00852551</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Chashitsu (Japanese tearooms)</str></doc>
                  <doc>
                    <str name="id">fst01144144</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea--Social aspects</str></doc>
                  <doc>
                    <str name="id">fst01144131</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tea--Health aspects</str></doc>
                  <doc>
                    <str name="id">fst00955319</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Herbal teas--Therapeutic use</str></doc>
                  <doc>
                    <str name="id">fst00981974</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Japanese tea masters</str></doc>
                  <doc>
                    <str name="id">fst01744455</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Chinese tea ceremony</str></doc>
                </result>
                </response>
      XML
    end

    # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
    let(:suggestions) do
      [
        {"Tea" => "http://id.worldcat.org/fast/1144120/::topic"},
        {"Tea Party movement" => "http://id.worldcat.org/fast/1762507/::topic"},
        {"Tea making paraphernalia" => "http://id.worldcat.org/fast/1144165/::topic"},
        {"Tea tax (American colonies)" => "http://id.worldcat.org/fast/1144178/::topic"},
        {"Tea trade" => "http://id.worldcat.org/fast/1144179/::topic"},
        {"Tea--Health aspects" => "http://id.worldcat.org/fast/1144131/::topic"},
        {"Tea--Social aspects" => "http://id.worldcat.org/fast/1144144/::topic"},
        {"Tea--Therapeutic use" => "http://id.worldcat.org/fast/1144148/::topic"},
        {"Tearooms" => "http://id.worldcat.org/fast/1144712/::topic"},
        {"East India Company" => "http://id.worldcat.org/fast/537796/::organization"}
      ]
    end

    before do
      url = "#{Settings.autocomplete_lookup.url}?q=keywords:(tea)#{other_params}"
      stub_request(:get, url).with(headers:).to_return(status: 200, body: lookup_resp_body, headers: {})
    end

    it "returns status 200 and html with suggestions" do
      get "/fast", params: {q: "tea"}
      expect(response).to have_http_status :ok

      match_suggestions(suggestions, response)
    end
  end

  context "when lookup is successful with wildcard" do
    let(:lookup_resp_body1) do
      <<~XML
                <?xml version="1.0" encoding="UTF-8"?>
                <response>
        #{"        "}
                <result name="response" numFound="2" start="0">
                  <doc>
                    <str name="id">fst00911692</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">English language--Study and teaching--Foreign speakers</str></doc>
                  <doc>
                    <str name="id">fst01787825</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Muzej Nikole Tesle</str></doc>
                </result>
                </response>
      XML
    end

    let(:lookup_resp_body2) do
      <<~XML
                <?xml version="1.0" encoding="UTF-8"?>
                <response>
        #{"        "}
                <lst name="responseHeader">
                  <int name="status">0</int>
                  <int name="QTime">0</int>
                  <lst name="params">
                    <str name="q">keywords:(tesl*)</str>
                    <str name="indent">on</str>
                    <str name="fl">id,fullphrase,type</str>
                    <str name="start">0</str>
                    <str name="sort">usage desc</str>
                    <str name="rows">20</str>
                    <str name="version">2.2</str>
                  </lst>
                </lst>
                <result name="response" numFound="24" start="0">
                  <doc>
                    <str name="id">fst00911692</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">English language--Study and teaching--Foreign speakers</str></doc>
                  <doc>
                    <str name="id">fst00028173</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Tesla, Nikola, 1856-1943</str></doc>
                  <doc>
                    <str name="id">fst01917360</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Tesla Motors</str></doc>
                  <doc>
                    <str name="id">fst01148179</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tesla coils</str></doc>
                  <doc>
                    <str name="id">fst00081416</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Teslenko, Arkhyp I︠U︡khymovych, 1882-1911</str></doc>
                  <doc>
                    <str name="id">fst01622914</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Teslin Tlingit Council</str></doc>
                  <doc>
                    <str name="id">fst01742752</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tesla Roadster automobile</str></doc>
                  <doc>
                    <str name="id">fst01787825</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Muzej Nikole Tesle</str></doc>
                  <doc>
                    <str name="id">fst00665529</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Tesla (Musical group)</str></doc>
                  <doc>
                    <str name="id">fst00483782</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Tesla, Nikola, 1856-1943 (Spirit)</str></doc>
                  <doc>
                    <str name="id">fst01292783</str>
                    <str name="type">geographic</str>
                    <str name="fullphrase">California--Tesla</str></doc>
                  <doc>
                    <str name="id">fst01311465</str>
                    <str name="type">geographic</str>
                    <str name="fullphrase">Canada--Teslin River</str></doc>
                  <doc>
                    <str name="id">fst01696224</str>
                    <str name="type">geographic</str>
                    <str name="fullphrase">Serbia--Nikola Tesla</str></doc>
                  <doc>
                    <str name="id">fst01850620</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Teslenko, Nikolaĭ V., 1870-1942</str></doc>
                  <doc>
                    <str name="id">fst01983442</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tesla Model S automobile</str></doc>
                  <doc>
                    <str name="id">fst00790766</str>
                    <str name="type">corporate</str>
                    <str name="fullphrase">Tesla Power Project</str></doc>
                  <doc>
                    <str name="id">fst01983485</str>
                    <str name="type">topic</str>
                    <str name="fullphrase">Tesla automobiles</str></doc>
                  <doc>
                    <str name="id">fst00494688</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Tesli︠a︡, Ivan</str></doc>
                  <doc>
                    <str name="id">fst01475215</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Teslenko, O. P. (Olʹga Pankratʹevna)</str></doc>
                  <doc>
                    <str name="id">fst01662813</str>
                    <str name="type">person</str>
                    <str name="fullphrase">Tesler, Oleg</str></doc>
                </result>
                </response>
      XML
    end

    # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
    let(:suggestions) do
      [
        {"Tesla (Musical group)" => "http://id.worldcat.org/fast/665529/::organization"},
        {"Tesla Model S automobile" => "http://id.worldcat.org/fast/1983442/::topic"},
        {"Tesla Motors" => "http://id.worldcat.org/fast/1917360/::organization"},
        {"Tesla Power Project" => "http://id.worldcat.org/fast/790766/::organization"},
        {"Tesla Roadster automobile" => "http://id.worldcat.org/fast/1742752/::topic"},
        {"Tesla automobiles" => "http://id.worldcat.org/fast/1983485/::topic"},
        {"Tesla coils" => "http://id.worldcat.org/fast/1148179/::topic"},
        {"Tesla, Nikola, 1856-1943" => "http://id.worldcat.org/fast/28173/::person"},
        {"Tesla, Nikola, 1856-1943 (Spirit)" => "http://id.worldcat.org/fast/483782/::person"},
        {"Teslenko, Arkhyp I︠U︡khymovych, 1882-1911" => "http://id.worldcat.org/fast/81416/::person"}
      ]
    end

    before do
      url1 = "#{Settings.autocomplete_lookup.url}?q=keywords:(tesl)#{other_params}"
      stub_request(:get, url1).with(headers:).to_return(status: 200, body: lookup_resp_body1, headers: {})
      url2 = "#{Settings.autocomplete_lookup.url}?q=keywords:(tesl*)#{other_params}"
      stub_request(:get, url2).with(headers:).to_return(status: 200, body: lookup_resp_body2, headers: {})
    end

    it "returns status 200 and html with suggestions" do
      get "/fast", params: {q: "tesl"}
      expect(response).to have_http_status :ok

      match_suggestions(suggestions, response)
    end
  end

  def match_suggestions(suggestions, response)
    suggestions.each do |suggestion|
      actual_suggestion = suggestion.keys.first
      uri = suggestion.values.first
      li_element_html = '<li class="list-group-item" role="option" ' \
                        "data-autocomplete-value=\"#{uri}\" data-autocomplete-label=\"#{actual_suggestion}\">" \
                        "#{ERB::Util.html_escape(actual_suggestion)}</li>"
      expect(response.body).to include(li_element_html)
    end
  end

  context "when error is received from the lookup server" do
    before do
      url = "#{Settings.autocomplete_lookup.url}?q=keywords:(tea)#{other_params}"
      stub_request(:get, url)
        .with(headers:)
        .to_return(status: [404, "some error message"], body: "", headers: {})
      allow(Rails.logger).to receive(:warn)
    end

    it "returns status 500 and an empty body" do
      get "/fast", params: {q: "tea"}
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to eq ""
      expect(Rails.logger).to have_received(:warn).with("Autocomplete results for tea returned 404")
    end
  end
end
