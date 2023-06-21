# frozen_string_literal: true

module Admin
  # Displays the drop down time selector for activity for the admin pages
  class ActivityTimeSelectorComponent < ApplicationComponent
    def initialize(path:, frame_id:, default_days: 7)
      @url = path
      @default_days = default_days
      @frame_id = frame_id
    end

    def dropdown
      options = options_for_select([["1 day", path_with_days(1)],
        ["7 days", path_with_days(7)],
        ["14 days", path_with_days(14)],
        ["30 days", path_with_days(30)]],
        path_with_days(@default_days))
      select_tag "path", options, class: "form-select",
        onchange: "document.querySelector('##{@frame_id}').src = this.value"
    end

    private

    def path_with_days(days)
      "#{@url}?days=#{days}"
    end
  end
end
