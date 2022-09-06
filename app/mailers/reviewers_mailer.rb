# frozen_string_literal: true

# Sends emails to people who review deposits
class ReviewersMailer < ApplicationMailer
  def submitted_email
    @user = UserPresenter.new(user: params[:user])
    @work_version = params[:work_version]
    @work = @work_version.work
    mail(to: @user.email, subject: "Item ready for review in the #{@work.collection_name} collection")
  end
end
