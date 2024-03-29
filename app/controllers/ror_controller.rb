# frozen_string_literal: true

# A proxy to ROR for typeahead
class RorController < ApplicationController
  include Dry::Monads[:result]

  def show
    result = lookup(params.require(:q))
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

  def lookup(query)
    resp = lookup_connection.get do |req|
      req.params['query'] = query
    end

    return Failure("Autocomplete results for #{query} returned #{resp.status}") unless resp.success?

    Success(parse(resp.body))
  end

  def parse(body)
    JSON.parse(body)['items'].map do |item|
      [item['id'], item['name'], details(item)]
    end
  end

  def details(item)
    [
      item['name'],
      location_detail(item),
      other_name_details(item)
    ].compact
  end

  def location_detail(item)
    city = item.dig('addresses', 0, 'city')
    country = item.dig('country', 'country_name')

    return "#{city}, #{country}" if city && country
    return country if country

    nil
  end

  def other_name_details(item)
    [].tap do |names|
      names.concat(item['acronyms'])
      names.concat(item['aliases'])
      names.concat(item['labels'].pluck('label'))
    end.join(', ')
  end

  def lookup_connection
    @lookup_connection ||= Faraday.new(
      url: Settings.ror_lookup.url,
      headers: {
        'Accept' => 'application/json',
        'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
      }
    )
  end
end
