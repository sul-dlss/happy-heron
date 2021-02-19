# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the release section of the collection (show page)
  class ReleaseComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :access, to: :collection

    def collection_version
      collection.head
    end

    sig { returns(T.nilable(String)) }
    def release_info
      case collection.release_option
      when 'immediate'
        'Immediately'
      when 'delay'
        "#{collection.release_duration} from date of deposit"
      when 'depositor-selects'
        "depositor selects release date at no more than #{collection.release_duration} from date of deposit"
      end
    end
  end
end
