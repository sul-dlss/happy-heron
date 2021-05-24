# typed: false
# frozen_string_literal: true

module Works
  # Renders a widget for specifying an embargo date on a work.
  class AvailableDateComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :embargo_date, to: :reform

    def reform
      form.object
    end

    def error?
      errors.present?
    end

    def error_message
      safe_join(errors.map(&:message), tag.br)
    end

    def errors
      reform.errors.where(:embargo_date)
    end

    # This field is required so that the form can't be submitted until it's filled in.
    # However, if it is marked as "disabled" (via complex_radio_controller.js) then
    # required is not applied. This is the desired behavior.
    def year_field
      select_year embargo_year,
                  {
                    prefix: 'work',
                    field_name: 'embargo_date(1i)',
                    start_year: Time.zone.today.year,
                    end_year: 3.years.from_now.year
                  },
                  data: {
                    auto_citation_target: 'embargoYear',
                    action: 'change->auto-citation#updateDisplay'
                  },
                  id: 'work_embargo_year',
                  required: true,
                  class: "form-control#{' is-invalid' if error?}"
    end

    # This field is required so that the form can't be submitted until it's filled in.
    # However, if it is marked as "disabled" (via complex_radio_controller.js) then
    # required is not applied. This is the desired behavior.
    def month_field
      select_month embargo_month,
                   { prefix: 'work', field_name: 'embargo_date(2i)', prompt: 'month' },
                   id: 'work_embargo_month',
                   required: true,
                   class: "form-control#{' is-invalid' if error?}"
    end

    # This field is required so that the form can't be submitted until it's filled in.
    # However, if it is marked as "disabled" (via complex_radio_controller.js) then
    # required is not applied. This is the desired behavior.
    def day_field
      select_day embargo_day,
                 { prefix: 'work', field_name: 'embargo_date(3i)', prompt: 'day' },
                 id: 'work_embargo_day',
                 required: true,
                 class: "form-control#{' is-invalid' if error?}"
    end

    def embargo_year
      embargo_date&.year || Time.zone.today.year
    end

    def embargo_month
      embargo_date&.month
    end

    def embargo_day
      embargo_date&.day
    end
  end
end
