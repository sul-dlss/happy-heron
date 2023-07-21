# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ror Controller" do
  let(:headers) do
    {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Stanford Self-Deposit (Happy Heron)"
    }
  end

  context "when lookup is successful" do
    let(:lookup_resp_body) do
      <<~JSON
        {
          "number_of_results": 2,
          "time_taken": 3,
          "items": [{
            "id": "https://ror.org/03mtd9a03",
            "name": "Stanford Medicine",
            "email_address": null,
            "ip_addresses": [],
            "established": 1959,
            "types": ["Healthcare"],
            "relationships": [{
              "label": "Stanford University",
              "type": "Related",
              "id": "https://ror.org/00f54p054"
            }],
            "addresses": [],
            "links": ["http://med.stanford.edu/"],
            "aliases": ["Stanford University Medical Center"],
            "acronyms": [],
            "status": "active",
            "wikipedia_url": "https://en.wikipedia.org/wiki/Stanford_University_Medical_Center",
            "labels": [],
            "country": {
              "country_name": "United States",
              "country_code": "US"
            },
            "external_ids": {
              "ISNI": {
                "preferred": null,
                "all": ["0000 0000 8734 2732"]
              },
              "OrgRef": {
                "preferred": null,
                "all": ["538014"]
              },
              "Wikidata": {
                "preferred": null,
                "all": ["Q7598810"]
              },
              "GRID": {
                "preferred": "grid.240952.8",
                "all": "grid.240952.8"
              }
            }
          }, {
            "id": "https://ror.org/00f54p054",
            "name": "Stanford University",
            "email_address": null,
            "ip_addresses": [],
            "established": 1891,
            "types": ["Education"],
            "relationships": [{
              "label": "Good Samaritan Hospital",
              "type": "Related",
              "id": "https://ror.org/03zms7281"
            }, {
              "label": "Lucile Packard Children's Hospital",
              "type": "Related",
              "id": "https://ror.org/05a25vm86"
            }, {
              "label": "SLAC National Accelerator Laboratory",
              "type": "Related",
              "id": "https://ror.org/05gzmn429"
            }, {
              "label": "Santa Clara Valley Medical Center",
              "type": "Related",
              "id": "https://ror.org/02v7qv571"
            }, {
              "label": "Stanford Medicine",
              "type": "Related",
              "id": "https://ror.org/03mtd9a03"
            }, {
              "label": "VA Palo Alto Health Care System",
              "type": "Related",
              "id": "https://ror.org/00nr17z89"
            }, {
              "label": "Brown Institute for Media Innovation",
              "type": "Child",
              "id": "https://ror.org/02awzbn54"
            }, {
              "label": "Center for Effective Global Action",
              "type": "Child",
              "id": "https://ror.org/03djjyk45"
            }, {
              "label": "Eterna Massive Open Laboratory",
              "type": "Child",
              "id": "https://ror.org/05j5wde68"
            }, {
              "label": "Kavli Institute for Particle Astrophysics and Cosmology",
              "type": "Child",
              "id": "https://ror.org/00pwqz914"
            }, {
              "label": "Max Planck Center for Visual Computing and Communication",
              "type": "Child",
              "id": "https://ror.org/03hj69t32"
            }, {
              "label": "CZ Biohub",
              "type": "Child",
              "id": "https://ror.org/00knt4f32"
            }],
            "addresses": [{
              "lat": 37.42411,
              "lng": -122.16608,
              "state": null,
              "state_code": null,
              "city": "Stanford",
              "geonames_city": {
                "id": 5398563,
                "city": "Stanford",
                "geonames_admin1": {
                  "name": "California",
                  "id": 5332921,
                  "ascii_name": "California",
                  "code": "US.CA"
                },
                "geonames_admin2": {
                  "name": "Santa Clara",
                  "id": 5393021,
                  "ascii_name": "Santa Clara",
                  "code": "US.CA.085"
                },
                "license": {
                  "attribution": "Data from geonames.org under a CC-BY 3.0 license",
                  "license": "http://creativecommons.org/licenses/by/3.0/"
                },
                "nuts_level1": {
                  "name": null,
                  "code": null
                },
                "nuts_level2": {
                  "name": null,
                  "code": null
                },
                "nuts_level3": {
                  "name": null,
                  "code": null
                }
              },
              "postcode": null,
              "primary": false,
              "line": null,
              "country_geonames_id": 6252001
            }],
            "links": ["http://www.stanford.edu/"],
            "aliases": ["Leland Stanford Junior University"],
            "acronyms": ["SU"],
            "status": "active",
            "wikipedia_url": "http://en.wikipedia.org/wiki/Stanford_University",
            "labels": [{
              "label": "Universidad Stanford",
              "iso639": "es"
            }],
            "country": {
              "country_name": "United States",
              "country_code": "US"
            },
            "external_ids": {
              "ISNI": {
                "preferred": null,
                "all": ["0000 0004 1936 8956"]
              },
              "FundRef": {
                "preferred": "100005492",
                "all": ["100005492", "100006521", "100008643", "100006100", "100010866", "100011098", "100006598", "100006057", "100005575", "100005541", "100006382"]
              },
              "OrgRef": {
                "preferred": "26977",
                "all": ["26977", "452927", "435330", "382431"]
              },
              "Wikidata": {
                "preferred": "Q41506",
                "all": ["Q41506", "Q1754977"]
              },
              "GRID": {
                "preferred": "grid.168010.e",
                "all": "grid.168010.e"
              }
            }
          }]
        }
      JSON
    end

    before do
      url = "#{Settings.ror_lookup.url}?query=stanford"
      stub_request(:get, url).with(headers:).to_return(status: 200, body: lookup_resp_body, headers: {})
    end

    it "returns status 200 and html with suggestions" do
      get "/ror", params: {q: "stanford"}
      expect(response).to have_http_status :ok

      match_suggestion("https://ror.org/03mtd9a03", "Stanford Medicine", "United States", "Stanford University Medical Center", response)
      match_suggestion("https://ror.org/00f54p054", "Stanford University", "Stanford, United States", "SU, Leland Stanford Junior University, Universidad Stanford", response)
    end

    def match_suggestion(uri, label, location, other_names, response)
      li_element_html = '<li class="list-group-item" role="option" ' \
                        "data-autocomplete-value=\"#{uri}\" data-autocomplete-label=\"#{label}\">"
      expect(response.body).to include(li_element_html)
      expect(response.body).to include(">#{label}</")
      expect(response.body).to include(">#{location}</")
      expect(response.body).to include(">#{other_names}</")
    end
  end

  context "when error is received from the lookup server" do
    before do
      url = "#{Settings.ror_lookup.url}?query=stanford"
      stub_request(:get, url)
        .with(headers:)
        .to_return(status: [404, "some error message"], body: "", headers: {})
      allow(Rails.logger).to receive(:warn)
    end

    it "returns status 500 and an empty body" do
      get "/ror", params: {q: "stanford"}
      expect(response).to have_http_status :internal_server_error
      expect(response.body).to eq ""
      expect(Rails.logger).to have_received(:warn).with("Autocomplete results for stanford returned 404")
    end
  end
end
