# typed: true
# frozen_string_literal: true

module Works
  # Renders a link to the collection edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(work_version: WorkVersion, anchor: String, label: String).void }
    def initialize(work_version:, anchor:, label:)
      @work_version = work_version
      @anchor = anchor
      @label = label
    end

    delegate :work, to: :work_version

    sig { returns(T::Boolean) }
    def render?
      work_version.can_update_metadata?
    end

    attr_reader :work_version, :anchor, :label
  end
end
