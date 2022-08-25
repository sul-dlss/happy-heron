# frozen_string_literal: true

# Handles approval
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def create
    version = Work.find(params[:work_id]).head
    authorize! version, to: :review?
    record_review(version)

    redirect_to dashboard_path
  end

  def record_review(version)
    if params[:state] == 'approve'
      version.work.event_context = { user: current_user }
      version.begin_deposit!
    else
      version.work.event_context = { description: params[:reason], user: current_user }
      version.reject!
    end
  end
end
