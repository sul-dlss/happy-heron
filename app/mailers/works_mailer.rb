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
    @user = UserPresenter.new(user: @work.depositor)
    subject = "Reminder: Deposit to the #{@work.collection_name} collection in the SDR is in progress"

    mail(to: @user.email, subject: subject)
  end

  def new_version_reminder_email
    @work = params[:work_version].work
    @user = UserPresenter.new(user: @work.depositor)

    subject = "Reminder: New version of a deposit to the #{@work.collection_name} collection in the SDR is in progress"

    mail(to: @user.email, subject: subject)
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
end
