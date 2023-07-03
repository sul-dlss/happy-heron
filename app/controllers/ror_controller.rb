# frozen_string_literal: true

# A proxy to ROR for typeahead
class RorController < ApplicationController
  include Dry::Monads[:result]

  def show
    result = lookup(params.require(:q))
    @suggestions = result.value_or([])
    if result.success?
      return render status: :no_content, html: "" if @suggestions.empty?

      render status: :ok, layout: false
    else
      logger.warn(result.failure)
      render status: :internal_server_error, html: ""
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def lookup(query)
    resp = lookup_connection.get do |req|
      req.params["query"] = query
    end

    return Failure("Autocomplete results for #{query} returned #{resp.status}") unless resp.success?

    Success(parse(resp.body))
  end
  # rubocop:enable Metrics/AbcSize

  def parse(body)
    JSON.parse(body)["items"].map do |item|
      [item["id"], item["name"]]
    end
  end

  def lookup_connection
    @lookup_connection ||= Faraday.new(
      url: Settings.ror_lookup.url,
      headers: {
        "Accept" => "application/json",
        "User-Agent" => "Stanford Self-Deposit (Happy Heron)"
      }
    )
  end
end
