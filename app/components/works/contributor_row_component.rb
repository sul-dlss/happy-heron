# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single contributor / author of the work.
  class ContributorRowComponent < ApplicationComponent
    def initialize(form:, is_author: false)
      @form = form
      @is_author = is_author
    end

    attr_reader :form

    def contributor?
      !@is_author
    end

    def author?
      @is_author
    end

    def select_role
      render ContributorRoleComponent.new(form: form, data_options: data_options_for_select)
    end

    def html_options(auto_citation_target, contributors_target: nil, disabled: false)
      {
        class: 'form-control',
        data: {
          contributors_target: contributors_target
        }.tap do |data|
          if author?
            data[:action] = 'change->auto-citation#updateDisplay'
            data[:auto_citation_target] = auto_citation_target
          end
        end.compact,
        required: author?,
        disabled: disabled
      }
    end

    def first_name_label
      with_required('First name')
    end

    def last_name_label
      with_required('Last name')
    end

    def role_term_label
      with_required('Role term')
    end

    def orcid_label
      with_required('ORCID iD')
    end

    def organization_label
      with_required('Organization Name')
    end

    def orcid?
      model.orcid.present?
    end

    def model
      form.object.class.method_defined?(:model) ? form.object.model : form.object
    end

    def html_options_for_delete
      {
        type: 'button',
        class: 'btn btn-sm',
        aria: { label: 'Remove' },
        data: {}.tap do |data|
          actions = ["contributors#remove #{form_controller}#removeAssociation"]
          actions << 'auto-citation#updateDisplay' if author?
          data[:action] = actions.join(' ')
        end
      }
    end

    def html_options_for_radio(is_name, checked)
      {
        checked: checked,
        data: {}.tap do |data|
          actions = ['contributors#personChanged']
          actions << 'auto-citation#updateDisplay' if author?
          data[:action] = actions.join(' ')
          data[:contributors_target] = 'personNameSelect' if is_name
        end,
        'aria-label': is_name ? 'Enter author by name' : 'Enter author by ORCID iD'
      }
    end

    private

    def form_controller
      contributor? ? 'nested-form' : 'ordered-nested-form'
    end

    def with_required(label)
      return label if contributor?

      "#{label} *"
    end

    def data_options_for_select
      {
        action: 'change->contributors#roleChanged change->auto-citation#updateDisplay',
        contributors_target: 'role'
      }.tap do |opts|
        actions = ['change->contributors#roleChanged']
        if author?
          opts[:auto_citation_target] = 'contributorRole'
          actions << ['change->auto-citation#updateDisplay']
        end
        opts[:action] = actions.join(' ')
      end
    end
  end
end
