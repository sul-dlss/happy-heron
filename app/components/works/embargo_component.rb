# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for defining an embargo on a work.
  class EmbargoComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :collection, to: :work

    def work
      form.object.model.fetch(:work)
    end

    # The access level is specified by the collection
    def user_can_set_access?
      return true if access_from_collection == 'depositor-selects'

      false
    end

    def user_can_set_availability?
      return false if already_immediately_released? || already_embargo_released?

      collection.user_can_set_availability?
    end

    def availability_from_collection
      if already_immediately_released?
        'This item was released immediately upon deposit.'
      elsif already_embargo_released?
        'This item has been released from embargo.'
      elsif collection.release_option == 'immediate'
        'Immediately upon deposit.'
      else
        "Starting on #{collection.release_date.to_formatted_s(:long)}."
      end
    end

    def access_from_collection
      collection.access
    end

    def when_available_statement
      return 'your deposit is approved' if collection.review_enabled?

      'you click "Deposit" at the bottom of this page'
    end

    delegate :already_immediately_released?, :already_embargo_released?, to: :work
  end
end
