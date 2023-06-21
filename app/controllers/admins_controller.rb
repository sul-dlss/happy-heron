# frozen_string_literal: true

# Displays the admin page
class AdminsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :admin_dashboard
    @presenter = AdminPresenter.new
  end

  def items_recent_activity
    authorize! :admin_dashboard
    @days_limit = params.fetch(:days, 7).to_i
    @items = Work.joins(:head).where("work_versions.updated_at > ?",
      @days_limit.days.ago).order("work_versions.updated_at DESC")
  end

  def collections_recent_activity
    authorize! :admin_dashboard
    @days_limit = params.fetch(:days, 7).to_i
    @collections = Collection.where("updated_at > ?", @days_limit.days.ago).order("updated_at DESC")
  end
end
