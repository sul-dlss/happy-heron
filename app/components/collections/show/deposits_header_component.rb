# frozen_string_literal: true

module Collections
  module Show
    # Renders the header for the collection deposits page.
    # This component ought to have a sibling component of Works::WorkTypeModalComponent
    # and it ought to be within a data-controller="work-type" attribute because
    # this component contains a button that acts on that controller
    class DepositsHeaderComponent < SettingsHeaderComponent
      def edit_button
        return unless draft?

        link_to "Edit or Deposit", edit_collection_version_path(collection_version),
          class: "btn btn-outline-primary me-2"
      end
    end
  end
end
