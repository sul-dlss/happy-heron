# typed: false
# frozen_string_literal: true

module Collections
  # Renders the details about the work (show page)
  class InformationComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :creator, :druid, :version,
             to: :collection

    sig { returns(String) }
    def created
      format_date_string(collection.created_at)
    end

    sig { returns(String) }
    def last_saved
      format_date_string(collection.updated_at)
    end

    sig { returns(T.nilable(String)) }
    def purl
      return if collection.druid.nil?

      "https://purl.stanford.edu/#{collection.druid.gsub(/druid:/, '')}"
    end

    private

    def format_date_string(date)
      date.strftime('%B %e, %Y %I:%M%p')
    end
  end
end
