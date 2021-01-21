# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the release section of the collection (show page)
  class ReleaseComponent < Collections::ShowComponent
    delegate :release_option, :access, to: :collection
  end
end
