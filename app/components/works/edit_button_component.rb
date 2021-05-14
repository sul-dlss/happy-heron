# typed: false
# frozen_string_literal: true

module Works
  # Renders a button that links to the collection edit page
  class EditButtonComponent < ApplicationComponent
    sig { params(work_version: WorkVersion).void }
    def initialize(work_version:)
      @work_version = work_version
    end

    delegate :work, to: :work_version
    attr_reader :work_version

    sig { returns(T::Boolean) }
    def render?
      work_version.updatable?
    end

    def call
      link_to 'Edit or Deposit', edit_work_path(work), class: 'btn btn-outline-primary float-end'
    end
  end
end
