# typed: true
# frozen_string_literal: true

# Sends emails to people who review deposits
class ReviewersMailer < ApplicationMailer
  def submitted_email
    @user = params[:user]
    @work = params[:work]
    mail(to: @user.email, subject: "New deposit activity in the #{@work.collection_name} collection")
  end
end
