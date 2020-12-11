# typed: true
# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class FormComponent < ApplicationComponent
    attr_reader :collection_form

    sig { params(collection_form: DraftCollectionForm).void }
    def initialize(collection_form:)
      @collection_form = collection_form
    end

    def release_date_year
      release_date&.year || Time.zone.today.year
    end

    def release_date_month
      release_date&.month
    end

    def release_date_day
      release_date&.day
    end

    sig { returns(T.nilable(Date)) }
    def release_date
      case reform.release_date
      when Date
        T.cast(reform.release_date, Date)
      end
    end

    sig { returns(DraftCollectionForm) }
    def reform
      collection_form
    end
  end
end
