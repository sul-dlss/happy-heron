# frozen_string_literal: true

module Collections
  # Renders the details section of the collection (show page)
  class DetailComponent < ApplicationComponent
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    attr_reader :collection_version

    delegate :name, :description, :version_description, :contact_emails, to: :collection_version
  end
end
