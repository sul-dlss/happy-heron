# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the header for the collection show page (title and create new link)
  class LinksComponent < Collections::ShowComponent
    delegate :related_links, to: :collection
  end
end
