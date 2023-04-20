# frozen_string_literal: true

module Admin
  # Generates work reports
  class PageContentController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def index
      authorize! :page_content
      @page_content = PageContent.find_by(page: 'home')
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize! :page_content

      page_content = PageContent.find_by(page: 'home')
      if page_content.update(page_content_params.merge(user: current_user))
        flash[:success] = I18n.t('admin.page_content.success')
      else
        flash[:error] = "#{I18n.t('admin.page_content.error')}: #{page_content.errors.full_messages.join(', ')}"
      end

      redirect_to admin_page_content_index_path
    end
    # rubocop:enable Metrics/AbcSize

    private

    def page_content_params
      params.require(:page_content).permit(:value, :visible)
    end
  end
end
