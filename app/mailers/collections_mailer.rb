# typed: true
# frozen_string_literal: true

# Sends email notifications about collections
class CollectionsMailer < ApplicationMailer
  def invitation_to_deposit_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Invitation to deposit to the #{@collection_version.name} collection in the SDR")
  end

  def deposit_access_removed_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your Depositor permissions for the #{@collection_version.name} " \
      'collection in the SDR have been removed')
  end

  def manage_access_granted_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "You are invited to participate as a Manager in the #{@collection_version.name} " \
      'collection in the SDR')
  end

  def manage_access_removed_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your permissions have changed for the #{@collection_version.name} " \
      'collection in the SDR')
  end

  def review_access_granted_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "You are invited to participate as a Reviewer in the #{@collection_version.name} " \
      'collection in the SDR')
  end

  def review_access_removed_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    @collection = @collection_version.collection
    mail(to: @user.email, subject: "Your permissions have changed for the #{@collection_version.name} " \
      'collection in the SDR')
  end

  def collection_activity
    @user = params[:user]
    @collection_version = params[:collection_version]
    @depositor = params[:depositor]

    mail(to: @user.email, subject: "New activity in the #{@collection_version.name} collection")
  end

  def participants_changed_email
    @user = params[:user]
    @collection_version = params[:collection_version]
    mail(to: @user.email, subject: "Participant changes for the #{@collection_version.name} collection in the SDR")
  end
end
