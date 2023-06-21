# frozen_string_literal: true

module Admin
  # Generates work reports
  class PageContentController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def index
      authorize! :page_content

      # NOTE: the user cannot create new pages, they are created manually in a migration
      # or on the rails console.  The user can then edit them.
      # As of April 2023, we only have one page in the database that can be edited, so just
      # shortcut to that edit view.  If we create more pages in the future, remove
      # this redirect, and this index page showing all available pages will be shown.
      redirect_to edit_admin_page_content_path(PageContent.find_by(page: "home"))

      @page_contents = PageContent.all
    end

    def edit
      authorize! :page_content

      @page_content = PageContent.find(params[:id])
    end

    def update
      authorize! :page_content

      @page_content = PageContent.find(params[:id])

      if @page_content.update(page_content_params.merge(user: current_user))
        flash[:success] = I18n.t("admin.page_content.success")
        redirect_to admin_page_content_index_path
      else
        render action: "edit", status: :unprocessable_entity
      end
    end

    private

    def page_content_params
      params.require(:page_content).permit(:value, :visible, :link_visible, :link_url, :link_text)
    end
  end
end
