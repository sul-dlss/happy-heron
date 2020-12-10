# typed: false
# frozen_string_literal: true

module Works
  # Renders a widget for defining an embargo on a work.
  class EmbargoComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :embargo_date, to: :reform

    def reform
      form.object
    end

    def year_field
      select_year embargo_year,
                  {
                    prefix: 'work',
                    field_name: 'embargo_date(1i)',
                    start_year: Time.zone.today.year,
                    end_year: 3.years.from_now.year
                  },
                  id: 'work_embargo_year',
                  class: 'form-control'
    end

    def month_field
      select_month embargo_month,
                   { prefix: 'work', field_name: 'embargo_date(2i)', prompt: 'month' },
                   id: 'work_embargo_month',
                   class: 'form-control'
    end

    def day_field
      select_day embargo_day,
                 { prefix: 'work', field_name: 'embargo_date(3i)', prompt: 'day' },
                 id: 'work_embargo_day',
                 class: 'form-control'
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
