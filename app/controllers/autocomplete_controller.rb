# typed: false
# frozen_string_literal: true

# A proxy to Settings.autocomplete_lookup.url to get OCLC's FAST data for typeahead
class AutocompleteController < ApplicationController
  def show
    query = params.require(:q)
    lookup_resp = lookup(query)
    if lookup_resp.success? || lookup_resp.status == :no_content
      @suggestions = suggestions(lookup_resp.body)
      render status: :no_content, text: '' if @suggestions.empty?
    else
      logger.warn("Autocomplete results for #{query} returned #{lookup_resp.status}")
      @suggestions = []
      render status: :internal_server_error, text: ''
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def lookup(query)
    lookup_connection.get do |req|
      req.params['query'] = query
      req.params['queryIndex'] = Settings.autocomplete_lookup.query_index
      req.params['queryReturn'] = URI::DEFAULT_PARSER.escape(Settings.autocomplete_lookup.query_return)
      req.params['rows'] = Settings.autocomplete_lookup.num_records
      req.params['suggest'] = 'autoSubject'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def lookup_connection
    @lookup_connection ||= Faraday.new(
      url: Settings.autocomplete_lookup.url,
      headers: {
        'Accept' => 'application/json',
        'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
      }
    )
  end

  # returns the first ten deduplicated _authorized_ forms of FAST terms that match the entered letters.
  # transform the response to return an array of the first 10 unique hashes
  #   key: the authorized form of suggestion and
  #   value: the uri for the OCLC FAST record.
  def suggestions(lookup_response)
    return [] if lookup_response.blank?

    parsed = JSON.parse(lookup_response)
    result = parsed['response']['docs'].map { |doc| { doc['auth'] => authority_uri(doc['idroot']) } }.flatten
    result.uniq.first(10)
  end

  URI_PREFIX = 'http://id.worldcat.org/fast/'

  def authority_uri(idroot)
    "#{URI_PREFIX}#{idroot.delete_prefix('fst').to_i}/"
  end
end
