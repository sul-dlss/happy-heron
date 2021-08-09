# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single contributor to the work.
  class ContributorRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def not_first_contributor?
      form.index != 0
    end

    def select_role
      render ContributorRoleComponent.new(form: form, data_options: data_options_for_select)
    end

    def data_options_for_select
      {
        action: 'change->contributors#typeChanged',
        contributors_target: 'role'
      }
    end

    def html_options(contributors_target, _auto_citation_target)
      {
        class: 'form-control',
        data: {
          contributors_target: contributors_target
        }
      }
    end

    # First name label

    def first_name_label
      'First name'
    end

    # Last name label

    def last_name_label
      'Last name'
    end

    # Role term label

    def role_term_label
      'Role term'
    end
  end
end
