# typed: true
# frozen_string_literal: true

# This generates a the Access cocina model for a work
class AccessGenerator
  extend T::Sig

  sig { params(work: Work).returns(Hash) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(Hash) }
  def generate
    return { access: work.access, download: work.access } unless work.embargo_date

    { access: 'citation-only', download: 'none', embargo: { access: 'world', releaseDate: work.embargo_date.iso8601 } }
  end

  private

  attr_reader :work
end
