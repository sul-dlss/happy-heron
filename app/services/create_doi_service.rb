# typed: true
# frozen_string_literal: true

# Mint a DOI from Datacite
class CreateDoiService
  def self.call
    result = client.autogenerate_doi(prefix: Settings.datacite.prefix)
    result.either(
      ->(response) { response.doi },
      ->(response) { raise StandardError, "Something went wrong #{response.status}\n#{response.body}" }
    )
  end

  def self.client
    Datacite::Client.new(username: Settings.datacite.username,
                         password: Settings.datacite.password,
                         host: Settings.datacite.host)
  end
  private_class_method :client
end
