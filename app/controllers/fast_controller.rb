# frozen_string_literal: true

# A proxy to Settings.autocomplete_lookup.url to get OCLC's FAST data for typeahead
class FastController < ApplicationController
  include Dry::Monads[:result]

  def show
    result = lookups(params.require(:q))
    @suggestions = result.value_or([])
    if result.success?
      return render status: :no_content if @suggestions.empty?

      render status: :ok, layout: false
    else
      logger.warn(result.failure)
      render status: :internal_server_error, html: ''
    end
  end

  private

  def lookups(query)
    result = lookup(query)
    return result if result.failure?

    Success(result.value!)
  end

  def lookup(query) # rubocop:disable Metrics/AbcSize
    response = lookup_connection.get do |req|
      req.params['query'] = ERB::Util.url_encode(query)
      req.params['queryIndex'] = 'suggestall'
      req.params['queryReturn'] = 'idroot,suggestall,tag'
      req.params['suggest'] = 'autoSubject'
      # Requesting extra records to try to increase the likelihood that get left anchored matches
      # since results are sorted by usage.
      req.params['rows'] = num_records * 2
      req.params['sort'] = 'usage desc'
    end

    return Success(parse(response.body)) if response.success?

    Honeybadger.notify('FAST API Error', context: { response: response.to_hash, params: params.to_unsafe_h })
    Failure("Autocomplete results for #{query} returned HTTP #{response.status}")
  rescue JSON::ParserError => e
    Honeybadger.notify('Unexpected response from FAST API',
                       context: { response: response.to_hash, params: params.to_unsafe_h, exception: e })
    Failure("Autocomplete results for #{query} returned unexpected response '#{response.body}'")
  end

  def parse(body)
    JSON.parse(body).dig('response', 'docs').map do |result|
      { result['suggestall'].first => key(result['idroot'].first, result['tag']) }
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

  def num_records
    Settings.autocomplete_lookup.num_records
  end

  URI_PREFIX = 'http://id.worldcat.org/fast/'
  private_constant :URI_PREFIX

  def key(idroot, type)
    "#{URI_PREFIX}#{idroot.delete_prefix('fst').to_i}/::#{cocina_type(type)}"
  end

  # Map of FAST tag types to Cocina types.
  TAG_TYPES = {
    100 => 'person',
    110 => 'organization',
    111 => 'conference',
    130 => 'title',
    147 => 'event',
    148 => 'time',
    151 => 'place',
    155 => 'genre'
  }.freeze
  private_constant :TAG_TYPES

  def cocina_type(type)
    TAG_TYPES.fetch(type, 'topic')
  end
end
