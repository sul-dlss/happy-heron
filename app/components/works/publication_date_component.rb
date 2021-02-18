# typed: false
# frozen_string_literal: true

module Works
  # Displays a form for providing publication date as an EDTF field
  class PublicationDateComponent < ApplicationComponent
    def initialize(form:, min_year:, max_year:)
      @form = form
      @min_year = min_year
      @max_year = max_year
    end

    attr_reader :form, :min_year, :max_year

    delegate :published_edtf, to: :reform

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
      reform.errors.where(:published_edtf)
    end

    def published_year
      published_edtf&.year
    end

    def published_month
      return unless published_edtf

      case published_edtf.precision
      when :month, :day
        published_edtf.month
      end
    end

    def published_day
      return unless published_edtf

      published_edtf.day if published_edtf.precision == :day
    end

    def year_field
      number_field_tag 'work[published(1i)]', published_year,
                       data: {
                         auto_citation_target: 'year',
                         date_validation_target: 'year',
                         action: 'change->auto-citation#updateDisplay date-validation#change'
                       },
                       id: 'work_published_year',
                       class: "form-control#{' is-invalid' if error?}",
                       min: min_year,
                       max: max_year
    end

    def month_field
      select_month published_month,
                   { prefix: 'work', field_name: 'published(2i)', prompt: 'month' },
                   data: {
                     date_validation_target: 'month',
                     action: 'date-validation#change'
                   },
                   id: 'work_published_month',
                   class: "form-control#{' is-invalid' if error?}"
    end

    def day_field
      select_day published_day,
                 { prefix: 'work', field_name: 'published(3i)', prompt: 'day' },
                 data: {
                   date_validation_target: 'day',
                   action: 'date-validation#change'
                 },
                 id: 'work_published_day',
                 class: "form-control#{' is-invalid' if error?}"
    end
  end
end
