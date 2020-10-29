# typed: strict
# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single contributor to the work.
  class ContributorRowComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form
  end
end
