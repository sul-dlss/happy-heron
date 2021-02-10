# typed: true
# frozen_string_literal: true

# This generates a the Access cocina model for a work
class AccessGenerator
  extend T::Sig

  sig { params(work_version: WorkVersion).returns(Hash) }
  def self.generate(work_version:)
    new(work_version: work_version).generate
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  sig { returns(Hash) }
  def generate
    return { access: work_version.access, download: work_version.access } unless work_version.embargo_date

    { access: 'citation-only', download: 'none',
      embargo: { access: 'world', releaseDate: work_version.embargo_date.iso8601 } }
  end

  private

  attr_reader :work_version
end
