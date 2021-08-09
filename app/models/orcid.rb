# frozen_string_literal: true

# Model for ORCID ids.
class Orcid
  PREFIX = 'https://orcid.org'
  SANDBOX_PREFIX = 'https://sandbox.orcid.org'
  # For example: https://orcid.org/0000-0003-1527-0030
  REGEX = %r{\A(#{PREFIX}|#{SANDBOX_PREFIX})/(\d{4}-\d{4}-\d{4}-\d{3}[0-9X])\Z}.freeze

  def self.split(orcid_id)
    match = REGEX.match(orcid_id)
    return [nil, nil] unless match

    [match[1], match[2]]
  end
end
