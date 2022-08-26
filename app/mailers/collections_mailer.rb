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
    @depositor = params[:depositor]

    mail(to: @user.email, subject: "New activity in the #{@collection_version.name} collection")
  end

  def item_deposited
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @depositor = params[:depositor]

    mail(to: @user.email, subject: "New activity in the #{@collection_version.name} collection")
  end

  def version_draft_created
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    @depositor = params[:depositor]

    mail(to: @user.email, subject: "New activity in the #{@collection_version.name} collection")
  end

  def participants_changed_email
    @user = UserPresenter.new(user: params[:user])
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "Participant changes for the #{@collection_version.name} collection in the SDR")
  end

  def new_version_reminder_email
    @collection_version = params[:collection_version]
    @user = UserPresenter.new(user: params[:user])

    subject = "Reminder: New version of your #{@collection_version.name} collection in the SDR is still in progress"

    mail(to: @user.email, subject: subject)
  end
end
