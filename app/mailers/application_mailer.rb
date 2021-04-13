# typed: false
# frozen_string_literal: true

# Base class for all mailers in the application.
class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@sdr.stanford.edu'
  layout 'mailer'
end
