# typed: false
# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single contributor to the work.
  class ContributorRowComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder, required: T::Boolean, citation: T::Boolean).void }
    def initialize(form:, required: false, citation: false)
      @form = form
      @required = required
      @citation = citation
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form

    sig { returns(T::Boolean) }
    def required?
      @required
    end

    sig { returns(T::Boolean) }
    def citation?
      @citation
    end

    sig { returns(T::Boolean) }
    def not_first_contributor?
      form.index != 0
    end

    delegate :grouped_collection_select, to: :form

    def select_role
      grouped_collection_select :role_term, grouped_options, :roles, :label, :key, :label,
                                {}, html_options_for_select
    end

    def html_options_for_select
      options = {
        class: 'form-select',
        data: {
          action: 'change->contributors#typeChanged',
          contributors_target: 'role'
        }
      }
      if citation?
        options[:data][:action] += ' change->auto-citation#updateDisplay'
        options[:data][:auto_citation_target] = 'contributorRole'
      end
      options
    end

    def html_options(contributors_target, auto_citation_target)
      options = {
        class: 'form-control',
        data: {
          action: 'change->contributors#inputChanged',
          contributors_target: contributors_target
        },
        required: required?
      }
      if citation?
        options[:data][:action] += ' change->auto-citation#updateDisplay'
        options[:data][:auto_citation_target] = auto_citation_target
      end

      options
    end

    # First name label
    sig { returns(String) }
    def first_name_label
      @required ? 'First name *' : 'First name'
    end

    # Last name label
    sig { returns(String) }
    def last_name_label
      @required ? 'Last name *' : 'Last name'
    end

    # Role term label
    sig { returns(String) }
    def role_term_label
      @required ? 'Role term *' : 'Role term'
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
    sig { returns(T::Array[ContributorType]) }
    def grouped_options
      %w[person organization].map do |key|
        ContributorType.new(key: key, citable: citation?)
      end
    end
  end
end
