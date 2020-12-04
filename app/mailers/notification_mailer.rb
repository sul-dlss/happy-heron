# typed: true
# frozen_string_literal: true

# Sends email notifications about works
class NotificationMailer < ApplicationMailer
  def reject_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: 'Your deposit has been reviewed and returned')
  end
end
