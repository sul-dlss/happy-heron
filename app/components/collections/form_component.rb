# typed: false
# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class FormComponent < ApplicationComponent
    attr_reader :collection_form

    delegate :release_duration, to: :collection_form

    sig { params(collection_form: DraftCollectionForm).void }
    def initialize(collection_form:)
      @collection_form = collection_form
    end

    def embargo_release_duration_options
      DraftCollectionForm::EMBARGO_RELEASE_DURATION_OPTIONS
    end

    def draft_collections_path(collection)
      collections_path(collection)
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
      case collection_form.release_date
      when Date
        T.cast(collection_form.release_date, Date)
      end
    end
  end
end
