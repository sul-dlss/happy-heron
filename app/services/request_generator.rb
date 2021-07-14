# typed: true
# frozen_string_literal: true

# This generates a RequestDRO for a work
class RequestGenerator
  extend T::Sig

  sig { params(work_version: WorkVersion).returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def self.generate_model(work_version:)
    new(work_version: work_version).generate_model
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  sig { returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def generate_model
    if druid
      Cocina::Models::DRO.new(model_attributes.merge(externalIdentifier: druid), false, false)
    else
      Cocina::Models::RequestDRO.new(model_attributes, false, false)
    end
  end

  private

  attr_reader :work_version

  delegate :work, to: :work_version
  delegate :druid, to: :work

  sig { returns(Hash) }
  def model_attributes
    {
      access: AccessGenerator.generate(work_version: work_version),
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo,
        partOfProject: Settings.h2.project_tag
      },
      identification: identification,
      structural: structural,
      label: work_version.title,
      type: cocina_type,
      description: DescriptionGenerator.generate(work_version: work_version),
      version: work_version.version
    }
  end

  sig { returns(Hash) }
  def identification
    {
      sourceId: "hydrus:object-#{work.id}",
      doi: work.doi
    }.compact
  end

  sig { returns(String) }
  def cocina_type
    WorkType.find(work_version.work_type).cocina_type
  end

  sig { returns(T.any(Cocina::Models::DROStructural, Cocina::Models::RequestDROStructural)) }
  def structural
    StructuralGenerator.generate(work_version: work_version)
  end
end
