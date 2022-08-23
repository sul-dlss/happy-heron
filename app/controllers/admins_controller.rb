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
    @events = Event.work_events.includes(:eventable).where('created_at > ?', @days_limit.days.ago)
  end
end
