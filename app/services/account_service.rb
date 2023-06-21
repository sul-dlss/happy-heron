# frozen_string_literal: true

# Retrieve names from the account API run by UIT
class AccountService
  def initialize
    pem_file = File.read(Settings.accountws.pem_file)
    @key = OpenSSL::PKey.read pem_file
    @cert = OpenSSL::X509::Certificate.new pem_file
  end

  def fetch(sunetid)
    Rails.cache.fetch(sunetid, namespace: "account", expires_in: 1.month) do
      url = template.partial_expand(sunetid:).pattern
      response = connection.get(url)
      doc = response.body
      doc.slice("name", "description")
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
