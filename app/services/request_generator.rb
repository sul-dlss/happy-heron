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
  # rubocop:disable Metrics/MethodLength
  def generate
    {
      administrative: {
        hasAdminPolicy: 'druid:pq757cd0790' # TODO: What should this be? this is the hydrus APO.
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
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :work
end
