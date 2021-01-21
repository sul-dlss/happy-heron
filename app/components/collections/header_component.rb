# typed: false
# frozen_string_literal: true

module Collections
  # Renders the header for the collection show page (title and create new link)
  class HeaderComponent < Collections::ShowComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :depositing?, to: :collection

    sig { returns(String) }
    def name
      collection.name.presence || 'No Title'
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end

    def can_create_work?
      helpers.allowed_to?(:create?, Work.new(collection: collection))
    end
  end
end
