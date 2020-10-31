# typed: true
# frozen_string_literal: true

# This generates a RequestDRO for a work
class RequestGenerator
  extend T::Sig

  sig { params(work: Work).returns(Cocina::Models::RequestDRO) }
  def self.generate_model(work:)
    new(work: work).generate_model
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  def generate_model
    Cocina::Models::RequestDRO.new(generate)
  end

  sig { returns(Hash) }
  def generate
    {
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo
      },
      identification: {
        sourceId: "hydrus:#{work.id}" # TODO: what should this be?
      },
      structural: {
        contains: []
      },
      label: work.title,
      type: Cocina::Models::Vocab.object, # TODO: use something based on worktype
      description: DescriptionGenerator.generate(work: work),
      version: 0
    }
  end

  private

  attr_reader :work
end
