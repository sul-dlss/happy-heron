# typed: false
# frozen_string_literal: true

module Collections
  # Renders the information section of the collection (show page)
  class InformationComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :creator, :druid, :version, :purl,
             to: :collection

    sig { returns(String) }
    def created
      format_date_string(collection.created_at)
    end

    sig { returns(String) }
    def last_saved
      format_date_string(collection.updated_at)
    end

    private

    def format_date_string(date)
      I18n.l(date, format: :abbr_month)
    end
  end
end
