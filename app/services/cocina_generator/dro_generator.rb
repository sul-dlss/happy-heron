# frozen_string_literal: true

module CocinaGenerator
  # This generates a RequestDRO for a work
  class DROGenerator
    def self.generate_model(work_version:)
      new(work_version: work_version).generate_model
    end

    def initialize(work_version:)
      @work_version = work_version
    end

    def generate_model
      if work_version.work.druid
        Cocina::Models::DRO.new(model_attributes.merge(externalIdentifier: work_version.work.druid), false, false)
      else
        Cocina::Models::RequestDRO.new(model_attributes, false, false)
      end
    end

    private

    attr_reader :work_version

    def model_attributes
      {
        access: AccessGenerator.generate(work_version: work_version),
        administrative: {
          hasAdminPolicy: Settings.h2.hydrus_apo,
          partOfProject: Settings.h2.project_tag
        },
        identification: {
          sourceId: "hydrus:object-#{work_version.work.id}" # TODO: what should this be?
        },
        structural: structural,
        label: work_version.title,
        type: cocina_type,
        description: Description::Generator.generate(work_version: work_version),
        version: work_version.version
      }
    end

    def cocina_type
      WorkType.find(work_version.work_type).cocina_type
    end

    def structural
      Structural::Generator.generate(work_version: work_version)
    end
  end
end
