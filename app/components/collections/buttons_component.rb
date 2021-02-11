# typed: false
# frozen_string_literal: true

module Collections
  # Displays the buttons for saving a draft or depositing for a collection
  class ButtonsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    sig { returns(T.nilable(String)) }
    def delete_button
      return unless persisted?

      helpers.turbo_frame_tag dom_id(model, :delete), src: delete_button_collection_path(model, style: :button)
    end

    sig { returns(T.nilable(String)) }
    def cancel_button
      render Collections::CancelComponent.new(collection: model)
    end

    delegate :object, to: :form
    delegate :model, to: :object
    delegate :persisted?, to: :model
  end
end
