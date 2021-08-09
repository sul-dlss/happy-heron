# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single author of the work.
  class AuthorRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def select_role
      render ContributorRoleComponent.new(form: form, data_options: data_options_for_select)
    end

    def data_options_for_select
      {
        action: 'change->contributors#typeChanged change->auto-citation#updateDisplay',
        contributors_target: 'role',
        auto_citation_target: 'contributorRole'
      }
    end

    def html_options(contributors_target, auto_citation_target)
      {
        class: 'form-control',
        data: {
          action: 'change->auto-citation#updateDisplay',
          contributors_target: contributors_target,
          auto_citation_target: auto_citation_target
        },
        required: true
      }
    end

    # First name label

    def first_name_label
      'First name *'
    end

    # Last name label

    def last_name_label
      'Last name *'
    end

    # Role term label

    def role_term_label
      'Role term *'
    end
  end
end
