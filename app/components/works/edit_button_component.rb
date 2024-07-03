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
     if work_version.purl_reservation?
        link_to 'Choose Type and Edit', '#', class: 'btn btn-outline-primary float-end',
                  data: {
                    destination: reservation_path(work),
                    form_method: 'patch',
                    bs_toggle: 'modal',
                    bs_target: '#workTypeModal',
                    action: 'work-type#setCollection'
                  },
                  aria: { label: 'Choose Type and Edit' }
      else
        link_to 'Edit or Deposit', edit_work_path(work), class: 'btn btn-outline-primary float-end', target: '_top'
      end
    end
  end
end
