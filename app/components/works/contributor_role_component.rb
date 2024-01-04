# frozen_string_literal: true

module Works
  # Renders a widget for selecting a contributor role
  class ContributorRoleComponent < ApplicationComponent
    def initialize(form:, data_options:, contributor_type:, visible:)
      @form = form
      @contributor_type = contributor_type # person or organization
      @visible = visible # if drop down starts out as hidden/disabled
      @data_options = data_options
    end

    attr_reader :form, :contributor_type, :visible

    delegate :grouped_collection_select, to: :form

    def call
      grouped_collection_select :role, grouped_options(contributor_type), :roles, :label, :key, :label,
                                {}, disabled: !visible, hidden: !visible, class: 'form-select',
                                    data: @data_options, 'aria-describedby': 'popover-work.role_term'
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
        AbstractContributor.grouped_roles(citable:)
                           .fetch(key).map { |label| Role.new(label:) }
      end
    end

    # Represents a role that may be selected for a specific type of contributor
    class Role
      def initialize(label:)
        @label = label
      end

      attr_reader :label

      def key
        label
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
