# typed: false
# frozen_string_literal: true

# Handles approval
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def create
    version = Work.find(params[:work_id]).head
    authorize! version, to: :review?
    if params[:state] == 'approve'
      version.begin_deposit!
    else
      version.work.event_context = { description: params[:reason], user: current_user }
      version.reject!
    end

    redirect_to dashboard_path
  end
end
