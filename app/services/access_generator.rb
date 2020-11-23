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
    {
      access: work.access,
      download: work.access
    }
  end

  private

  attr_reader :work
end
