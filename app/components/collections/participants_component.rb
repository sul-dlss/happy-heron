# typed: false
# frozen_string_literal: true

module Collections
  # Renders the participant section of the collection (show page)
  class ParticipantsComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    sig { returns(T.nilable(String)) }
    def depositors
      collection.depositors.pluck(:email).join(', ')
    end

    sig { returns(T.nilable(String)) }
    def managers
      collection.managers.pluck(:email).join(', ')
    end
  end
end
