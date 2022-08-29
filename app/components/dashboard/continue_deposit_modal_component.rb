# frozen_string_literal: true

module Dashboard
  # Display a modal prompting the user to see if they want to continue a deposit in progress (work or collection)
  class ContinueDepositModalComponent < ApplicationComponent
    def initialize(presenter:)
      @presenter = presenter
    end

    def render?
      @presenter.show_popup?
    end

    # if we have draft collections in progress, we will prioritize showing that over draft works in progress
    def deposit
      collection_version&.collection || work_version&.work
    end

    def deposit_version
      collection_version || work_version
    end

    # the last edited draft collection (if any)
    def collection_version
      @presenter.collection_managers_in_progress.first
    end

    # the last draft work (if any)
    def work_version
      @presenter.in_progress.first
    end

    def title
      @title ||= if deposit_version.instance_of?(WorkVersion)
                   WorkTitlePresenter.show(deposit_version)
                 else
                   CollectionTitlePresenter.show(deposit_version)
                 end
    end
  end
end
