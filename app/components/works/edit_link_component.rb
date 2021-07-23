# typed: true
# frozen_string_literal: true

module Works
  # Renders a link to the work edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(work_version: WorkVersion, anchor: String, label: T.nilable(String)).void }
    def initialize(work_version:, anchor:, label: nil)
      @work_version = work_version
      @anchor = anchor
      @label = label
    end

    delegate :work, to: :work_version

    sig { returns(T::Boolean) }
    def render?
      work_version.updatable?
    end

    attr_reader :work_version, :anchor, :label

    def choose_label
      label || "Choose Type and Edit #{title}"
    end

    def edit_label
      label || "Edit #{title}"
    end

    private

    def title
      WorkTitlePresenter.show(work_version)
    end
  end
end
