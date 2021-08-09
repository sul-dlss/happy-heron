# frozen_string_literal: true

module Works
  # Draws a widget for publication and creation dates
  class DatesComponent < ApplicationComponent
    def initialize(form:, min_year:, max_year:)
      @form = form
      @min_year = min_year
      @max_year = max_year
    end

    attr_reader :form, :min_year, :max_year

    def date_range_start_year
      number_field_tag "#{prefix}[created_range(1i)]", created_range_start_year,
                       data: {
                         date_validation_target: 'year',
                         date_range_target: 'startYear',
                         action: 'date-range#change clear->date-validation#clearValidations ' \
                                 'validate->date-validation#validate'
                       },
                       id: 'work_created_range_start_year',
                       placeholder: 'year',
                       class: 'form-control', min: min_year, max: max_year
    end

    def date_range_end_year
      number_field_tag "#{prefix}[created_range(4i)]", created_range_end_year,
                       data: {
                         date_validation_target: 'year',
                         date_range_target: 'endYear',
                         action: 'date-range#change clear->date-validation#clearValidations ' \
                                 'validate->date-validation#validate'
                       },
                       id: 'work_created_range_end_year',
                       placeholder: 'year',
                       class: 'form-control', min: min_year, max: max_year
    end

    def created_year
      created_edtf&.year
    end

    def created_month
      resolve_month(created_edtf)
    end

    def created_day
      resolve_day(created_edtf)
    end

    def created_approximate?
      return false unless created_edtf

      created_edtf.uncertain?
    end

    delegate :published_edtf, to: :reform

    # In getters below, reform.send is used to return the original submitted values are returned when an EDTF
    # couldn't be created.

    def created_range_start_year
      created_range_start&.year || reform.send(:'created_range(1i)').presence&.to_i
    end

    def created_range_start_month
      resolve_month(created_range_start) || reform.send(:'created_range(2i)').presence&.to_i
    end

    def created_range_start_day
      resolve_day(created_range_start) || reform.send(:'created_range(3i)').presence&.to_i
    end

    def created_range_start_approximate?
      return false unless created_range_start

      created_range_start.uncertain?
    end

    def created_range_end_year
      created_range_end&.year || reform.send(:'created_range(4i)').presence&.to_i
    end

    def created_range_end_month
      resolve_month(created_range_end) || reform.send(:'created_range(5i)').presence&.to_i
    end

    def created_range_end_day
      resolve_day(created_range_end) || reform.send(:'created_range(6i)').presence&.to_i
    end

    def created_range_end_approximate?
      return false unless created_range_end

      created_range_end.uncertain?
    end

    def created_range_start
      created_interval&.from
    end

    def created_range_end
      created_interval&.to
    end

    def created_interval
      case reform.created_edtf
      when EDTF::Interval
        reform.created_edtf
      end
    end

    def created_edtf
      case reform.created_edtf
      when Date
        reform.created_edtf
      end
    end

    def reform
      form.object
    end

    def prefix
      reform.model_name.param_key
    end

    private

    def resolve_day(created_date)
      return unless created_date

      created_date.day if created_date.precision == :day
    end

    def resolve_month(created_date)
      return unless created_date

      case created_date.precision
      when :month, :day
        created_date.month
      end
    end
  end
end
