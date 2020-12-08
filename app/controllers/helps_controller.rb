# typed: true
# frozen_string_literal: true

# The endpoint for the help modal
class HelpsController < ApplicationController
  def create
    HelpsMailer.with(name: params[:name],
                     email: params[:email],
                     affiliation: params[:affiliation],
                     help_how: params[:help_how],
                     why_contact: params[:why_contact])
               .jira_email.deliver_later
    render json: { status: 'success' }
  end
end
