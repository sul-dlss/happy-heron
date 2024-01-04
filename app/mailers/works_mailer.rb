# frozen_string_literal: true

# Sends email notifications about works
class WorksMailer < ApplicationMailer
  def approved_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: 'Your deposit has been reviewed and approved')
  end

  def deposited_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: "Your deposit, #{@work_version.title}, is published in the SDR")
  end

  def first_draft_reminder_email
    @work = params[:work_version].work
    @user = UserPresenter.new(user: @work.owner)
    subject = "Reminder: Deposit to the #{@work.collection_name} collection in the SDR is in progress"
    mail(to: @user.email, subject:)
  end

  def new_version_reminder_email
    @work = params[:work_version].work
    @user = UserPresenter.new(user: @work.owner)

    subject = "Reminder: New version of a deposit to the #{@work.collection_name} collection in the SDR is in progress"

    mail(to: @user.email, subject:)
  end

  def new_version_deposited_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: "A new version of #{@work_version.title} has been deposited in the SDR")
  end

  def reject_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: 'Your deposit has been reviewed and returned')
  end

  def submitted_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: 'Your deposit is submitted and waiting for approval')
  end

  def changed_owner_email
    @work = params[:work]
    @user = UserPresenter.new(user: @work.owner)
    mail(to: @user.email, subject: 'You now have access to an item in the SDR')
  end

  def changed_owner_collection_manager_email
    @work = params[:work]
    @user = UserPresenter.new(user: params[:user])
    mail(to: @user.email, subject: 'The ownership of an item in your collection has changed')
  end

  def globus_deposited_email
    @work_version = params[:work_version]
    @work = @work_version.work
    @user = UserPresenter.new(user: @work.owner)
    mail(to: Settings.notifications.admin_email, subject: 'User has deposited an item with files on Globus')
  end

  def decommission_owner_email
    @work_version = params[:work_version]
    @user = UserPresenter.new(user: @work_version.work.owner)
    mail(to: @user.email, subject: 'Your item has been removed from the Stanford Digital Repository')
  end

  def decommission_manager_email
    work_version = params[:work_version]
    @work_title = work_version.title
    @collection_name = work_version.work.collection_name
    @user = UserPresenter.new(user: params[:user])
    mail(to: @user.email, subject: 'An item in your collection has been removed from the Stanford Digital Repository')
  end

  def globus_endpoint_created
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: 'Upload your files to the SDR using Globus')
  end

  def version_mismatch_email
    @work = params[:work]
    @user = @work.owner
    @work_title = @work.head.title
    @collection_name = @work.collection_name
    mail(to: Settings.notifications.admin_email, subject: 'An H2 version mismatch error has occurred')
  end
end
