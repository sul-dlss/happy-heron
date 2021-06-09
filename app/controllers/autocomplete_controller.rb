# typed: false
# frozen_string_literal: true

# A proxy to Settings.autocomplete_lookup.url to get OCLC's FAST data for typeahead
class AutocompleteController < ApplicationController
  def show
    query = params.require(:q)
    lookup_resp = lookup(query)
    if lookup_resp.success? || lookup_resp.status == :no_content
      render status: lookup_resp.status, json: lookup_resp.body
    else
      logger.warn("Autocomplete results for #{query} returned #{lookup_resp.status}")
      render status: :internal_server_error, json: ''
    end
  end

  private

  def lookup(query)
    lookup_connection.get do |req|
      req.params['q'] = query
      req.params['maxRecords'] = Settings.autocomplete_lookup.max_records
    end
  end

  def lookup_connection
    @lookup_connection ||= Faraday.new(
      url: Settings.autocomplete_lookup.url,
      headers: {
        'Accept' => 'application/json',
        'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
      }
    )
  end
end
