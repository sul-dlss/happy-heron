# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for DOI.
  class DoiComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    private

    attr_reader :form

    def work
      form.object.model.fetch(:work)
    end

    def doi
      work.doi ? "https://doi.org/#{work.doi}" : nil
    end

    def collection_doi_option
      work.collection.doi_option
    end
  end
end
