# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
  class AccountServiceHiccough < StandardError; end

  def initialize
    pem_file = File.read(Settings.accountws.pem_file)
    @key = OpenSSL::PKey.read pem_file
    @cert = OpenSSL::X509::Certificate.new pem_file
  end

  def fetch(sunetid)
    # Never write a `nil` to the cache or legit users will have bogus cache
    # entries for the duration of the expiry period (one month)
    Rails.cache.fetch(sunetid, namespace: 'account', expires_in: 1.month, skip_nil: true) do
      url = template.partial_expand(sunetid:).pattern

      # The account service frequently returns 500 errors. Retry the connection five times in rapid succession.
      begin
        tries ||= 1
        response_body = connection.get(url).body
        # Raise and retry if the response is an HTTP 500.
        #
        # If, on the other hand, a bogus sunetid is provided, the `status` of the response will be 404, and then we:
        #
        # 1. Do *not* want to retry; but
        # 2. *Do* want to cache the empty document
        raise AccountServiceHiccough if response_body['status'] == 500

        # Write the user's name and description to the cache, *or* write an
        # empty document to the cache if the response is a 404, as that response
        # has no `name` and `description` keys.
        response_body.slice('name', 'description')
      rescue AccountServiceHiccough
        retry if (tries += 1) <= 5

        # Prevent writing to the cache of all connection attempts error out
        nil
      end
    end
  end

  private

  attr_reader :key, :cert

  def template
    @template ||= Addressable::Template.new("https://#{Settings.accountws.host}/accounts/{sunetid}")
  end

  def connection
    Faraday::Connection.new(ssl: {
                              client_cert: cert,
                              client_key: key,
                              verify: false
                            }) do |conn|
      conn.response :json
    end
  end
end
