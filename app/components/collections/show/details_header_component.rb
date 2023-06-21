# frozen_string_literal: true

module Collections
  module Show
    # Renders the header for the collection details show page (title and create new link)
    class DetailsHeaderComponent < SettingsHeaderComponent
      def edit_button
        return unless draft?

        link_to "Edit or Deposit", edit_collection_version_path(collection_version),
          class: "btn btn-outline-primary me-2"
      end
    end
  end
end
