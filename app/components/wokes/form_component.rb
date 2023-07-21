# frozen_string_literal: true

module Wokes
  # The component that renders the form for editing or creating a work.
  class FormComponent < ApplicationComponent
    attr_reader :form

    def initialize(form:)
      @form = form
    end

    def url
      form.persisted? ? woke_path(id: form.id) : collection_wokes_path(collection_id: form.collection_id)
    end

    def doi_field
      return "https://doi.org/#{form.doi}." if form.doi

      # create DOI URL or placeholder for works in collections that allow DOI assignment
      return unless form.will_assign_doi?

      return "https://doi.org/#{Doi.for(form.druid)}." if form.druid

      WorkVersion::DOI_TEXT
    end
  end
end
