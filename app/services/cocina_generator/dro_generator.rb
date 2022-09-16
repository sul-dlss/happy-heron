# frozen_string_literal: true

module CocinaGenerator
  # This generates a RequestDRO for a work
  class DROGenerator
    def self.generate_model(work_version:)
      new(work_version:).generate_model
    end

    def initialize(work_version:)
      @work_version = work_version
    end

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

    def model_attributes # rubocop:disable Metrics/AbcSize
      {
        access: AccessGenerator.generate(work_version:),
        administrative: {
          hasAdminPolicy: Settings.h2.hydrus_apo
        },
        identification:,
        structural:,
        label: work_version.title,
        type: cocina_type,
        description: Description::Generator.generate(work_version:).to_h,
        version: work_version.version
      }.tap do |h|
        h[:administrative][:partOfProject] = Settings.h2.project_tag unless druid
      end
    end

    def identification
      {
        sourceId: "hydrus:object-#{work.id}",
        doi:
      }.compact
    end

    delegate :doi, to: :work

    def cocina_type
      WorkType.find(work_version.work_type).cocina_type
    end

    def structural
      Structural::Generator.generate(work_version:)
    end
  end
end
