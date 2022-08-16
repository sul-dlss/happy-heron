# frozen_string_literal: true

module Admin
  # Displays the drop down navigation for the admin pages
  class NavigationComponent < ApplicationComponent
    def dropdown
      options = options_for_select([['Admin page', admin_path], ['Search for user', admin_users_path]],
                                   request.env['PATH_INFO'])
      select_tag 'path', options, class: 'form-select', onchange: 'window.location.href = this.value'
    end
  end
end
