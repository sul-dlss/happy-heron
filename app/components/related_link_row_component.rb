# typed: strict
# frozen_string_literal: true

# Renders a widget for describing a related link.
class RelatedLinkRowComponent < ApplicationComponent
  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form:)
    @form = form
  end

  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  delegate :link_title, to: :model_instance

  sig { returns(T::Boolean) }
  def not_first_link?
    form.index != 0
  end

  sig { returns(T.any(RelatedLink, Reform::Form)) }
  def model_instance
    form.object
  end
end
