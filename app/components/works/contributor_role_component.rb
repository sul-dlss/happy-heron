# frozen_string_literal: true

module Works
  # Renders a widget for selecting a contributor role
  class ContributorRoleComponent < ApplicationComponent
    def initialize(form:, data_options:, contributor_type:)
      @form = form
      @contributor_type = contributor_type # person or organization
      @data_options = data_options
    end

    attr_reader :form, :contributor_type

    delegate :grouped_collection_select, to: :form

    def call
      grouped_collection_select :role_term, grouped_options(contributor_type), :roles, :label, :key, :label,
        {}, class: "form-select", data: @data_options, "aria-describedby": "popover-work.role_term"
    end

    # Represents the type of contributor top level option for the role select
    class ContributorType
      def initialize(key:, citable:)
        @key = key
        @citable = citable
      end

      attr_reader :key, :citable

      def label
        I18n.t(key, scope: "contributor.roles")
      end

      def roles
        AbstractContributor.grouped_roles(citable:)
          .fetch(key).map { |label| Role.new(contributor_type: key, label:) }
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
        [contributor_type, label].join(AbstractContributor::SEPARATOR)
      end
    end

    # list for work_form pulldown

    def grouped_options(contributor_type)
      [contributor_type].map do |key|
        ContributorType.new(key:, citable: false)
      end
    end
  end
end
