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

    # rubocop:disable Metrics/AbcSize
    def options
      opts = [
        ['Select...', 'select'],
        ['Change owner', edit_owners_path(work)],
        ['Lock/Unlock', edit_locks_path(work)],
        ['Move to another collection', edit_move_path(work)]
      ]
      opts << ['Decommission', edit_work_decommission_path(work)] unless work.head.decommissioned?
      opts << ['Change work type', edit_work_types_path(work)] if change_work_type?
      options_for_select(opts, 'select')
    end
    # rubocop:enable Metrics/AbcSize

    def change_work_type?
      %i[reserving_purl purl_reserved first_draft pending_approval rejected depositing version_draft
         decommissioned].exclude?(work.head.state.to_sym)
    end
  end
end
