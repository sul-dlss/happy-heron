# frozen_string_literal: true

# Sends email notifications about collections
class CollectionsMailer < ApplicationMailer
  def invitation_to_deposit_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Invitation to deposit to the #{@collection_version.name} collection in the SDR")
  end

  def deposit_access_removed_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your Depositor permissions for the #{@collection_version.name} " \
                                   'collection in the SDR have been removed')
  end

  def manage_access_granted_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "You are invited to participate as a Manager in the #{@collection_version.name} " \
                                   'collection in the SDR')
  end

  def manage_access_removed_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your permissions have changed for the #{@collection_version.name} " \
                                   'collection in the SDR')
  end

  def review_access_granted_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "You are invited to participate as a Reviewer in the #{@collection_version.name} " \
                                   'collection in the SDR')
  end

  def review_access_removed_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your permissions have changed for the #{@collection_version.name} " \
                                   'collection in the SDR')
  end

  def first_draft_created
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @owner = params[:owner]
    @work = params[:work]

    mail(to: @user.email, subject: "Draft item created in the #{@collection_version.name} collection")
  end

  def first_draft_reminder_email
    @collection_version = params[:collection_version]
    @user = UserPresenter.new(user: params[:user])

    subject = "Reminder: Your #{@collection_version.name} collection in the SDR is still in progress"

    mail(to: @user.email, subject:)
  end

  def new_version_reminder_email
    @collection_version = params[:collection_version]
    @user = UserPresenter.new(user: params[:user])

    subject = "Reminder: Updates to your #{@collection_version.name} collection in the SDR is still in progress"

    mail(to: @user.email, subject:)
  end

  def item_deposited
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @owner = params[:owner]
    @work = params[:work]

    mail(to: @user.email, subject: "Item deposit completed in the #{@collection_version.name} collection")
  end

  def version_draft_created
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @owner = params[:owner]
    @work = params[:work]

    mail(to: @user.email, subject: "New draft created in the #{@collection_version.name} collection")
  end

  def participants_changed_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "Participant changes for the #{@collection_version.name} collection in the SDR")
  end

  def decommission_manager_email
    @collection_version = params[:collection_version]
    @user = UserPresenter.new(user: params[:user])
    mail(to: @user.email, subject: 'Your collection has been removed from the Stanford Digital Repository')
  end
end
