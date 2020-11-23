# typed: true
# frozen_string_literal: true

# This generates a RequestDRO for a work
class RequestGenerator
  extend T::Sig

  sig { params(work: Work).returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def self.generate_model(work:)
    new(work: work).generate_model
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def generate_model
    if work.druid
      Cocina::Models::DRO.new(model_attributes.merge(externalIdentifier: work.druid), false, false)
    else
      Cocina::Models::RequestDRO.new(model_attributes, false, false)
    end
  end

  private

  attr_reader :work

  sig { returns(Hash) }
  def model_attributes
    {
      access: access,
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo
      },
      identification: {
        sourceId: "hydrus:#{work.id}" # TODO: what should this be?
      },
      structural: structural,
      label: work.title,
      type: cocina_type,
      description: DescriptionGenerator.generate(work: work),
      version: work.version
    }
  end

  sig { returns(String) }
  def cocina_type
    WorkType.find(work.work_type).cocina_type
  end

  sig { returns(Hash) }
  # TODO: This varies based on what the user selected
  def access
    {
      access: 'stanford',
      download: 'stanford'
    }
  end

  sig { returns(T.any(Cocina::Models::DROStructural, Cocina::Models::RequestDROStructural)) }
  def structural
    StructuralGenerator.generate(work: work)
  end
end
