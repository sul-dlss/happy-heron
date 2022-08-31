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
    new_owner = User.find_or_create_by(email: "#{params['sunetid']}@stanford.edu")

    if work.owner == new_owner
      flash[:error] = I18n.t('work.flash.owner_not_updated')
    else
      update_owner(work, new_owner)
    end
    redirect_to work_path(work)
  end

  private

  def update_owner(work, new_owner)
    move_work_to_new_owner(work, new_owner)
    send_emails(work)
    flash[:success] = I18n.t('work.flash.owner_updated')
  end

  def send_emails(work)
    send_participant_change_emails(work.collection)
    send_changed_owner_email(work)
    send_collection_managers_email(work)
  end

  def send_participant_change_emails(collection)
    (collection.managed_by + collection.reviewed_by).uniq.each do |user|
      CollectionsMailer.with(collection_version: collection.head, user: user)
                       .participants_changed_email.deliver_later
    end
  end

  def send_changed_owner_email(work)
    WorksMailer.with(work: work).changed_owner_email.deliver_later
  end

  def send_collection_managers_email(work)
    work.collection.managed_by.each do |user|
      WorksMailer.with(work: work, user: user).changed_owner_collection_manager_email.deliver_later
    end
  end

  def move_work_to_new_owner(work, new_owner)
    orig_owner = work.owner

    Work.transaction do
      change_owner(work, new_owner)
      create_event(work, new_owner, orig_owner)
      add_depositor_to_collection(work.collection, new_owner)
    end
  end

  def add_depositor_to_collection(collection, depositor)
    collection.depositors << depositor unless collection.depositors.include?(depositor)
    collection.save!
  end

  def change_owner(work, owner)
    work.owner = owner
    work.save!
  end

  def create_event(work, new_owner, orig_owner)
    work.events.create(work.event_context.merge(event_type: 'update_owner',
                                                description: "from #{orig_owner.sunetid} to #{new_owner.sunetid}"))
  end
end
