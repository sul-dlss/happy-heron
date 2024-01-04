# frozen_string_literal: true

module CocinaGenerator
  # This generates a the Access cocina model for a work
  class AccessGenerator
    def self.generate(work_version:)
      new(work_version:).generate
    end

    def initialize(work_version:)
      @work_version = work_version
    end

    def generate
      access = work_version.embargo_date ? embargoed_access : regular_access

      base_access.merge(access)
    end

    private

    attr_reader :work_version

    def regular_access
      {
        view: work_version.access,
        download: work_version.access
      }
    end

    def embargoed_access
      {
        view: 'citation-only',
        download: 'none',
        embargo: regular_access.merge({ releaseDate: work_version.embargo_date.iso8601 })
      }
    end

    def base_access
      {
        license: License.find(work_version.license).uri.presence,
        useAndReproductionStatement: rights_statement
      }.compact
    end

    def rights_statement
      [work_version.custom_rights, Settings.access.use_and_reproduction_statement].compact.join("\n\n")
    end
  end
end
