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
      resolve_month(created_edtf)
    end

    def created_day
      resolve_day(created_edtf)
    end

    def created_approximate?
      return false unless created_edtf

      T.must(created_edtf).uncertain?
    end

    delegate :published_edtf, to: :reform

    def created_range_start_year
      created_range_start&.year
    end

    def created_range_start_month
      resolve_month(created_range_start)
    end

    def created_range_start_day
      resolve_day(created_range_start)
    end

    def created_range_start_approximate?
      return false unless created_range_start

      T.must(created_range_start).uncertain?
    end

    def created_range_end_year
      created_range_end&.year
    end

    def created_range_end_month
      resolve_month(created_range_end)
    end

    def created_range_end_day
      resolve_day(created_range_end)
    end

    def created_range_end_approximate?
      return false unless created_range_end

      T.must(created_range_end).uncertain?
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

    private

    sig { params(created_date: T.nilable(Date)).returns(T.nilable(Integer)) }
    def resolve_day(created_date)
      return unless created_date

      created_date.day if created_date.precision == :day
    end

    sig { params(created_date: T.nilable(Date)).returns(T.nilable(Integer)) }
    def resolve_month(created_date)
      return unless created_date

      case created_date.precision
      when :month, :day
        created_date.month
      end
    end
  end
end
