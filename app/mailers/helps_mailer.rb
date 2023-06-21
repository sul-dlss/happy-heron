# frozen_string_literal: true

# The endpoint for the help modal
class HelpsMailer < ApplicationMailer
  def jira_email
    email = params[:email]
    subject = params[:help_how]

    @name = params[:name]
    @affiliation = params[:affiliation]
    @why_contact = params[:why_contact]
    @collections = params[:collections]

    mail(to: ["sdr-support@jirasul.stanford.edu", "sdr-contact@lists.stanford.edu"],
      from: email,
      subject:)
  end
end
