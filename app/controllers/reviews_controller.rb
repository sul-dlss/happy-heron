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
      work.begin_deposit!
    else
      work.events.create!(user: current_user, event_type: 'reject', description: params[:reason])
      work.reject!
    end

    redirect_to dashboard_path
  end
end
