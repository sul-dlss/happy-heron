# frozen_string_literal: true

module Works
  # Renders the admin functions for a work
  class AdminComponent < ApplicationComponent
    def initialize(work:)
      @work = work
    end

    attr_reader :work

    def render?
      helpers.user_with_groups.administrator?
    end

    def options
      opts = [
        ['Select...', 'select'],
        ['Change owner', edit_owners_path(work)],
        ['Lock/Unlock', edit_locks_path(work)]
      ]
      opts << ['Decommission', edit_work_decommission_path(work)] unless work.head.decommissioned?
      options_for_select(opts, 'select')
    end
  end
end
