# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single contributor to the work.
  class ContributorRowComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form

    sig { returns(T::Boolean) }
    def not_first_contributor?
      form.index != 0
    end

    delegate :grouped_collection_select, to: :form

    def select_role
      grouped_collection_select :role_term, grouped_options, :roles, :label, :key, :label,
                                {}, class: 'form-select',
                                    data: {
                                      action: 'change->contributors#typeChanged change->auto-citation#updateDisplay',
                                      target: 'contributors.role auto-citation.contributorRole'
                                    }
    end

    # Represents the type of contributor top level option for the role select
    class ContributorType
      def initialize(key:)
        @key = key
      end

      attr_reader :key

      def label
        I18n.t(key, scope: 'contributor.roles')
      end

      def roles
        Contributor::GROUPED_ROLES.fetch(key).map { |label| Role.new(contributor_type: key, label: label) }
      end
    end

    # Represents a role that may be selected for a specific type of contributor
    class Role
      def initialize(contributor_type:, label:)
        @contributor_type = contributor_type
        @label = label
      end

      attr_reader :label, :contributor_type

      def key
        [contributor_type, label].join(Contributor::SEPARATOR)
      end
    end

    # list for work_form pulldown
    sig { returns(T::Array[ContributorType]) }
    def grouped_options
      %w[person organization].map do |key|
        ContributorType.new(key: key)
      end
    end
  end
end
