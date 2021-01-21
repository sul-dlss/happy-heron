# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the terms of use section of the collection (show page)
  class TermsOfUseComponent < Collections::ShowComponent
    delegate :default_license, to: :collection
  end
end
