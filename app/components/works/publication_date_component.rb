# typed: false
# frozen_string_literal: true

module Works
  # Displays a form for providing publication date as an EDTF field
  class PublicationDateComponent < ApplicationComponent
    def initialize(published_edtf:, min_year:, max_year:)
      @published_edtf = published_edtf
      @min_year = min_year
      @max_year = max_year
    end

    attr_reader :published_edtf, :min_year, :max_year

    def published_year
      published_edtf&.year
    end

    def published_month
      published_edtf&.month
    end

    def published_day
      published_edtf&.day
    end

    def year_field
      number_field_tag 'work[published(1i)]', published_year,
                       data: {
                         auto_citation_target: 'year',
                         date_validation_target: 'year',
                         action: 'change->auto-citation#updateDisplay date-validation#change'
                       },
                       id: 'work_published_year',
                       class: 'form-control',
                       min: min_year,
                       max: max_year
    end

    def month_field
      select_month published_month,
                   { prefix: 'work', field_name: 'published(2i)', prompt: 'month' },
                   data: {
                     auto_citation_target: 'month',
                     date_validation_target: 'month',
                     action: 'change->auto-citation#updateDisplay date-validation#change'
                   },
                   id: 'work_published_month',
                   class: 'form-control'
    end

    def day_field
      select_day published_day,
                 { prefix: 'work', field_name: 'published(3i)', prompt: 'day' },
                 data: {
                   auto_citation_target: 'day',
                   date_validation_target: 'day',
                   action: 'change->auto-citation#updateDisplay date-validation#change'
                 },
                 id: 'work_published_day',
                 class: 'form-control'
    end
  end
end
