# typed: true
# frozen_string_literal: true

# This looks up a name from ORCID.org
class OrcidService
  extend T::Sig

  sig { params(orcid: String).returns(T.any(Dry::Monads::Result::Success, Dry::Monads::Result::Failure)) }
  def self.lookup(orcid:)
    new(orcid: orcid).lookup
  end

  sig { params(orcid: String).void }
  def initialize(orcid:)
    @orcid = orcid
  end

  sig { returns(T.any(Dry::Monads::Result::Success, Dry::Monads::Result::Failure)) }
  def lookup
    return clean_orcid_result if clean_orcid_result.failure?

    resp = Faraday.new.get(url, {}, headers)
    return Dry::Monads::Result::Failure.new(resp.status) unless resp.success?

    resp_json = JSON.parse(resp.body)
    Dry::Monads::Result::Success.new([resp_json.dig('name', 'given-names', 'value'),
                                      resp_json.dig('name', 'family-name', 'value')])
  end

  private

  attr_reader :orcid

  def clean_orcid_result
    @clean_orcid_result ||= begin
      match = /[0-9xX]{4}-[0-9xX]{4}-[0-9xX]{4}-[0-9xX]{4}/.match(orcid)
      match ? Dry::Monads::Result::Success.new(match[0]&.upcase) : Dry::Monads::Result::Failure.new(400)
    end
  end

  def url
    "https://pub.orcid.org/v3.0/#{clean_orcid_result.value!}/personal-details"
  end

  def headers
    {
      'Accept' => 'application/json',
      'User-Agent' => 'Stanford Self-Deposit (Happy Heron)'
    }
  end
end
