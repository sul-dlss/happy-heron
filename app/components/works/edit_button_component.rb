# frozen_string_literal: true

module Works
  # Renders a button that links to the work edit page
  # This should be within a container styled with .clearfix
  class EditButtonComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    delegate :work, to: :work_version
    attr_reader :work_version

    def render?
      work_version.draft?
    end

    def call
      link_to 'Edit or Deposit', edit_work_path(work), class: 'btn btn-outline-primary float-end', target: '_top'
    end
  end
end
