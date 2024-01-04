# frozen_string_literal: true

# Provides nested contributor and author forms for works and drafts
module ContributorForm
  extend ActiveSupport::Concern

  class_methods do
    def has_contributors(validate:)
      has_generic_contributors(validate:)
      has_authors(validate:)
    end

    def has_generic_contributors(validate:)
      collection :contributors,
                 populator: ContributorPopulator.new(:contributors, Contributor),
                 prepopulator: ->(*) { contributors << Contributor.new if contributors.blank? },
                 on: :work_version,
                 &form_properties(validate:)
    end

    def has_authors(validate:)
      collection :authors,
                 populator: ContributorPopulator.new(:authors, Author),
                 prepopulator: ->(*) { authors << Author.new if authors.blank? },
                 on: :work_version,
                 &form_properties(validate:)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def form_properties(validate:)
      lambda { |*_args|
        property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
        property :first_name
        property :last_name
        property :full_name
        property :orcid
        property :role
        property :contributor_type
        property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
        property :weight, type: Dry::Types['params.nil'] | Dry::Types['params.integer']

        collection :affiliations,
                   populator: AffiliationsPopulator.new(:affiliations, Affiliation),
                   prepopulator: ->(*) { affiliations << Affiliation.new if affiliations.blank? } do
          property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
          property :label, type: Dry::Types['params.nil'] | Dry::Types['params.string']
          property :uri, type: Dry::Types['params.nil'] | Dry::Types['params.string']
          property :department, type: Dry::Types['params.nil'] | Dry::Types['params.string']
          property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
          validates :label, presence: true if validate
        end

        if validate
          validates :first_name, presence: true, if: -> { contributor_type == 'person' }
          validates :last_name, presence: true, if: -> { contributor_type == 'person' }
          validates :full_name, presence: true, unless: -> { contributor_type == 'person' }
        end
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
