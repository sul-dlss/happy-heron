# typed: true
# frozen_string_literal: true

# The endpoint for the help modal
class HelpsMailer < ApplicationMailer
  def send_jira(email, subject, body)
    message = mail(to: 'sdr-support@jirasul.stanford.edu',
                   from: email,
                   subject: subject,
                   body: body)
    message.deliver!
  end
end
