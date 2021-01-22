# typed: true
# frozen_string_literal: true

module Works
  # Renders a link to the collection edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(work: Work, anchor: String, label: String).void }
    def initialize(work:, anchor:, label:)
      @work = work
      @anchor = anchor
      @label = label
    end

    attr_reader :work, :anchor, :label
  end
end
