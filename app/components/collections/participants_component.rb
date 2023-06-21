# frozen_string_literal: true

module Collections
  # Renders the participant section of the collection (show page)
  class ParticipantsComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    def depositors
      collection.depositors.map(&:sunetid).join(", ")
    end

    def managers
      collection.managed_by.map(&:sunetid).join(", ")
    end
  end
end
