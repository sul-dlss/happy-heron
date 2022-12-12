# frozen_string_literal: true

module CocinaGenerator
  ID_NAMESPACE = 'https://cocina.sul.stanford.edu'

  # This generates a RequestDRO for a work
  class DROGenerator
    def self.generate_model(work_version:, cocina_obj: nil)
      new(work_version:, cocina_obj:).generate_model
    end

    def initialize(work_version:, cocina_obj:)
      @work_version = work_version
      @cocina_obj = cocina_obj # may be nil
    end

    def generate_model
      if cocina_obj
        Cocina::Models::DRO.new(model_attributes.merge(externalIdentifier: cocina_obj.externalIdentifier), false, false)
      else
        Cocina::Models::RequestDRO.new(model_attributes, false, false)
      end
    end

    private

    attr_reader :work_version, :cocina_obj

    delegate :work, to: :work_version

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
        h[:administrative][:partOfProject] = Settings.h2.project_tag unless cocina_obj
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
      Structural::Generator.generate(work_version:, cocina_obj:)
    end
  end
end
