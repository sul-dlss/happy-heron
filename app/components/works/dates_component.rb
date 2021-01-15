# typed: true
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

    def created_year
      created_edtf&.year
    end

    def created_month
      created_edtf&.month
    end

    def created_day
      created_edtf&.day
    end

    delegate :published_edtf, to: :reform

    def created_range_start_year
      created_range_start&.year
    end

    def created_range_start_month
      created_range_start&.month
    end

    def created_range_start_day
      created_range_start&.day
    end

    def created_range_end_year
      created_range_end&.year
    end

    def created_range_end_month
      created_range_end&.month
    end

    def created_range_end_day
      created_range_end&.day
    end

    sig { returns(T.nilable(Date)) }
    def created_range_start
      created_interval&.begin
    end

    sig { returns(T.nilable(Date)) }
    def created_range_end
      created_interval&.end
    end

    sig { returns(T.nilable(EDTF::Interval)) }
    def created_interval
      case reform.created_edtf
      when EDTF::Interval
        T.cast(reform.created_edtf, EDTF::Interval)
      end
    end

    sig { returns(T.nilable(Date)) }
    def created_edtf
      case reform.created_edtf
      when Date
        T.cast(reform.created_edtf, Date)
      end
    end

    sig { returns(DraftWorkForm) }
    def reform
      form.object
    end

    def radio_button_options(type:)
      { class: 'form-check-input' }.tap do |options|
        options[:checked] = true if (type == 'range' && created_interval) ||
                                    (type == 'single' && created_edtf)
      end
    end
  end
end
