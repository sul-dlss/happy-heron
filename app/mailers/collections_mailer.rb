# typed: false
# frozen_string_literal: true

# Sends email notifications about collections
class CollectionsMailer < ApplicationMailer
  def invitation_to_deposit_email
    @user = params[:user]
    @collection = params[:collection]
    mail(to: @user.email, subject: "Invitation to deposit to the #{@collection.name} collection in the SDR")
  end

  def deposit_access_removed_email
    @user = params[:user]
    @collection = params[:collection]
    mail(to: @user.email, subject: "Your Depositor permissions for the #{@collection.name} " \
      'collection in the SDR have been removed')
  end

  def manage_access_granted_email
    @user = params[:user]
    @collection = params[:collection]
    mail(to: @user.email, subject: "You are invited to participate as a Manager in the #{@collection.name} " \
      'collection in the SDR')
  end

  def manage_access_removed_email
    @user = params[:user]
    @collection = params[:collection]
    mail(to: @user.email, subject: "Your permissions have changed for the #{@collection.name} collection in the SDR")
  end

  def review_access_granted_email
    @user = params[:user]
    @collection = params[:collection]
    mail(to: @user.email, subject: "You are invited to participate as a Reviewer in the #{@collection.name} " \
      'collection in the SDR')
  end
end
