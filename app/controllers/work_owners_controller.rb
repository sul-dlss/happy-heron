# frozen_string_literal: true

# a controller for the owners for a work.
class WorkOwnersController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    authorize! :work_owner
  end

  def update
    authorize! :work_owner

    work = Work.find(params[:id])
    orig_owner = work.owner
    new_owner = User.find_or_create_by(email: "#{params['sunetid']}@stanford.edu")
    change_owner(work, new_owner)
    create_event(work, new_owner, orig_owner)

    flash[:success] = I18n.t('work.flash.owner_updated')
    redirect_to work_path(work)
  end

  private

  def change_owner(work, owner)
    work.owner = owner
    work.save!
  end

  def create_event(work, new_owner, orig_owner)
    work.events.create(work.event_context.merge(event_type: 'update_owner',
                                                description: "from #{orig_owner.sunetid} to #{new_owner.sunetid}"))
  end
end
