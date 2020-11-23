# typed: strict
# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single file attached to the work.
  class FileRowComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form

    sig { returns(T.nilable(ActiveStorage::Filename)) }
    def filename
      return unless uploaded?

      form.object.model.filename
    end

    sig { returns(T::Boolean) }
    def uploaded?
      form.object.persisted?
    end
  end
end
