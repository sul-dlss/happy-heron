# typed: true
# frozen_string_literal: true

# Sends email notifications about works
class NotificationMailer < ApplicationMailer
  def approved_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: 'Your deposit has been reviewed and approved')
  end

  def deposited_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: "Your deposit, #{@work.title}, is published in the SDR")
  end

  def new_version_deposited_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: "A new version of #{@work.title} has been deposited in the SDR")
  end

  def reject_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: 'Your deposit has been reviewed and returned')
  end
end
