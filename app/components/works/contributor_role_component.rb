# frozen_string_literal: true

module Works
  # Renders a widget for selecting a contributor role
  class ContributorRoleComponent < ApplicationComponent
    def initialize(form:, data_options:)
      @form = form
      @data_options = data_options
    end

    attr_reader :form

    delegate :grouped_collection_select, to: :form

    def call
      grouped_collection_select :role_term, grouped_options, :roles, :label, :key, :label,
                                {}, class: 'form-select', data: @data_options
    end

    # Represents the type of contributor top level option for the role select
    class ContributorType
      def initialize(key:, citable:)
        @key = key
        @citable = citable
      end

      attr_reader :key, :citable

      def label
        I18n.t(key, scope: 'contributor.roles')
      end

      def roles
        AbstractContributor.grouped_roles(citable: citable)
                           .fetch(key).map { |label| Role.new(contributor_type: key, label: label) }
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

    def grouped_options
      %w[person organization].map do |key|
        ContributorType.new(key: key, citable: false)
      end
    end
  end
end
