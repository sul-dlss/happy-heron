# typed: false
# frozen_string_literal: true

# Handles approval
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def create
    work = Work.find(params[:work_id])
    authorize! work, to: :review?
    if params[:state] == 'approve'
      EventService.begin_deposit(work: work, user: current_user)
      DepositJob.perform_later(work)
    else
      EventService.reject(work: work, user: current_user, description: params[:reason])
    end

    redirect_to dashboard_path
  end
end
