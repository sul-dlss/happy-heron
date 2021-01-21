# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the participant section of the collection (show page)
  class ParticipantsComponent < Collections::ShowComponent
    sig { returns(T.nilable(String)) }
    def depositors
      collection.depositors.map(&:sunetid).join(', ')
    end

    sig { returns(T.nilable(String)) }
    def managers
      collection.managers.map(&:sunetid).join(', ')
    end
  end
end
