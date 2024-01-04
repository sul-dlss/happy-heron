# frozen_string_literal: true

module CocinaGenerator
  module Description
    # generates Cocina::Models::DescriptiveValue to be used by ContributorsGenerator
    class AffiliationsGenerator
      def self.generate(contributor:)
        new(contributor:).generate
      end

      def initialize(contributor:)
        @contributor = contributor
      end

      def generate
        contributor.affiliations.map do |affiliation|
          generate_affiliation(affiliation)
        end
      end

      private

      attr_reader :contributor

      def generate_affiliation(affiliation)
        params = if affiliation.department.present?
                   {
                     type: 'affiliation',
                     structuredValue: [
                       generate_descriptive_value_by_label(affiliation),
                       {
                         value: affiliation.department
                       }
                     ]
                   }
                 else
                   {
                     type: 'affiliation'
                   }.merge(generate_descriptive_value_by_label(affiliation))
                 end
        Cocina::Models::DescriptiveValue.new(params)
      end

      def generate_descriptive_value_by_label(affiliation)
        {
          value: affiliation.label,
          identifier: generate_identifier(affiliation)
        }.compact
      end

      def generate_identifier(affiliation)
        return nil if affiliation.uri.blank?

        [
          {
            uri: affiliation.uri,
            type: 'ROR',
            source: {
              code: 'ror'
            }
          }
        ]
      end
    end
  end
end
