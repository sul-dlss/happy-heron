# frozen_string_literal: true

# a controller for the admins to lock/unlock a work.
class WorkLocksController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    authorize! :work_lock
    @work = Work.find(params[:id])
  end

  def update
    authorize! :work_lock

    change_lock_status = ActiveModel::Type::Boolean.new.cast(params[:change_lock_status])
    work = Work.find(params[:id])
    change_state(work, change_lock_status)
    create_event(work, change_lock_status)

    flash[:success] = (change_lock_status ? I18n.t('work.flash.work_locked') : I18n.t('work.flash.work_unlocked'))
    redirect_to work_path(work)
  end

  private

  def change_state(work, lock_state)
    work.locked = lock_state
    work.save!
  end

  def create_event(work, lock_state)
    event_type = lock_state ? 'lock_work' : 'unlock_work'
    work.events.create(work.event_context.merge(event_type:))
  end

  def update_lock_params
    params.permit(:change_lock_status)
  end
end
