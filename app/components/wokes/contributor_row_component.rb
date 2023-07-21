# frozen_string_literal: true

module Wokes
  # Renders a widget corresponding to a single contributor / author of the work.
  class ContributorRowComponent < ApplicationComponent
    def initialize(form:, controller:, ordered: false)
      @form = form
      @controller = controller
      @ordered = ordered
    end

    attr_reader :form, :controller

    def ordered?
      @ordered
    end

    def contributor?
      !author?
    end

    def author?
      contributor.is_a?(Author)
    end

    def html_options(auto_citation_target, contributors_target: nil, disabled: false)
      {
        class: "form-control",
        data: {
          contributors_target:
        }.tap do |data|
          if author?
            data[:action] = "change->auto-citation#updateDisplay"
            data[:auto_citation_target] = auto_citation_target
          end
        end.compact,
        required: author?,
        disabled:
      }
    end

    def first_name_label
      with_required("First name")
    end

    def last_name_label
      with_required("Last name")
    end

    def role_term_label
      with_required("Role term")
    end

    def orcid_label
      with_required("ORCID iD")
    end

    def organization_label
      with_required("Organization Name")
    end

    def orcid?
      contributor.orcid.present?
    end

    def contributor
      form.object.contributor
    end

    def contributor_remove_label
      "Remove #{contributor_name.blank? ? "blank #{contributor.class.name.downcase}" : contributor_name}"
    end

    def contributor_name
      contributor.full_name.blank? ? "#{contributor.first_name} #{contributor.last_name}".strip : contributor.full_name
    end

    def html_options_for_delete
      {
        class: "btn btn-sm",
        aria: {label: contributor_remove_label},
        data: {}.tap do |data|
          data[:action] = "auto-citation#updateDisplay" if author?
        end
      }
    end

    def html_options_for_radio(is_name, checked)
      {
        checked:,
        class: "form-check-input",
        data: {}.tap do |data|
          actions = ["contributors#personChanged"]
          actions << "auto-citation#updateDisplay" if author?
          data[:action] = actions.join(" ")
          data[:contributors_target] = "personNameSelect" if is_name
        end,
        "aria-label": is_name ? "Enter contributor by name" : "Enter contributor by ORCID iD"
      }
    end

    def with_required(label)
      return label if contributor?

      "#{label} *"
    end

    def data_options_for_select
      {
        action: "change->contributors#roleChanged change->auto-citation#updateDisplay",
        contributors_target: "role"
      }.tap do |opts|
        actions = ["change->contributors#roleChanged"]
        if author?
          opts[:auto_citation_target] = "contributorRole"
          actions << ["change->auto-citation#updateDisplay"]
        end
        opts[:action] = actions.join(" ")
      end
    end
  end
end
