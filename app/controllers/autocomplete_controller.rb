# typed: false
# frozen_string_literal: true

# A proxy to Settings.autocomplete_lookup.url to get OCLC's FAST data for typeahead
class AutocompleteController < ApplicationController
  T.unsafe(self).include Dry::Monads[:result]

  def show
    result = lookups(params.require(:q))
    @suggestions = result.value_or([])
    if result.success?
      render status: :no_content, html: '' and return if @suggestions.empty?

      render status: :ok, layout: false
    else
      logger.warn(result.failure)
      render status: :internal_server_error, html: ''
    end
  end

  private

  def lookups(query)
    # Try first without wildcard.
    result = lookup(query)
    return result if result.failure?

    suggestions = result.value!
    if suggestions.size < num_records
      # If not enough results then add wildcard.
      wildcard_result = lookup(query, wildcard: true)
      wildcard_suggestions = wildcard_result.value_or([])
    end

    Success(merge_suggestions(suggestions, wildcard_suggestions, query))
  end

  # rubocop:disable Metrics/AbcSize
  def lookup(query, wildcard: false)
    resp = lookup_connection.get do |req|
      req.params['q'] = wildcard ? "keywords:(#{query}*)" : "keywords:(#{query})"
      # Requesting extra records to try to increase the likelihood that get left anchored matches
      # since results are sorted by usage.
      req.params['rows'] = num_records * 2
      req.params['start'] = 0
      req.params['version'] = '2.2'
      req.params['indent'] = 'on'
      req.params['fl'] = 'id,fullphrase'
      req.params['sort'] = 'usage desc'
    end

    return Failure("Autocomplete results for #{query} returned #{resp.status}") unless resp.success?

    Success(parse(resp.body))
  end
  # rubocop:enable Metrics/AbcSize

  def parse(body)
    ng = Nokogiri::XML(body)
    ng.root.xpath('/response/result/doc').map do |doc_node|
      id = doc_node.at_xpath('str[@name="id"]').content
      label = doc_node.at_xpath('str[@name="fullphrase"]').content
      { label => authority_uri(id) }
    end
  end

  def lookup_connection
    @lookup_connection ||= Faraday.new(
      url: Settings.autocomplete_lookup.url,
      headers: {
        'Accept' => 'application/xml',
        'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
      }
    )
  end

  def num_records
    Settings.autocomplete_lookup.num_records
  end

  # Split into left-anchored matches to query and other matches.
  def partition_suggestions(suggestions, query)
    Array(suggestions).partition { |suggestion| suggestion.keys.first.downcase.start_with?(query.downcase) }
  end

  def merge_suggestions(suggestions1, suggestions2, query)
    left_match_suggestions1, other_suggestions1 = partition_suggestions(suggestions1, query)
    left_match_suggestions2, other_suggestions2 = partition_suggestions(suggestions2, query)

    # Order is left match (non-wildcard) alpha, left match (wildcard) alpha, other matches alpha
    left_match_suggestions = (sort_suggestions(left_match_suggestions1) + sort_suggestions(left_match_suggestions2))
                             .take(num_records)
    num_other_suggestions = num_records - left_match_suggestions.size
    other_suggestions = (other_suggestions1 + other_suggestions2)
                        .uniq
                        .take(num_other_suggestions)

    left_match_suggestions + sort_suggestions(other_suggestions)
  end

  def sort_suggestions(suggestions)
    suggestions.sort { |suggestion1, suggestion2| suggestion1.keys.first <=> suggestion2.keys.first }
  end

  URI_PREFIX = 'http://id.worldcat.org/fast/'

  def authority_uri(idroot)
    "#{URI_PREFIX}#{idroot.delete_prefix('fst').to_i}/"
  end
end
