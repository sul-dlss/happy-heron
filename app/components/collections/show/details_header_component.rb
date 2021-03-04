# typed: false
# frozen_string_literal: true

module Collections
  module Show
    # Renders the header for the collection details show page (title and create new link)
    class DetailsHeaderComponent < SettingsHeaderComponent
      def edit_link
        link_to edit_collection_version_path(collection_version), aria: { label: "Edit #{name}" } do
          tag.span class: 'fas fa-pencil-alt edit'
        end
      end
    end
  end
end
