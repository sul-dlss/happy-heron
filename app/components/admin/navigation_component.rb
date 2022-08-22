# frozen_string_literal: true

module Admin
  # Displays the drop down navigation for the admin pages
  class NavigationComponent < ApplicationComponent
    def dropdown
      options = options_for_select([['Admin page', admin_path],
                                    ['Search for DRUID', admin_druid_searches_path],
                                    ['Search for user', admin_users_path],
                                    ['Generate collection report', new_admin_collection_report_path],
                                    ['Generate item report', new_admin_work_report_path]],
                                   request.env['PATH_INFO'])
      select_tag 'path', options, class: 'form-select', onchange: 'window.location.href = this.value'
    end
  end
end
