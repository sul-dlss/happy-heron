# frozen_string_literal: true

# The endpoint for the help modal
class HelpsController < ApplicationController
  def new
    @email = current_user&.email
    @help_how_value = 'I want to become an SDR depositor' unless current_user
  end

  # You can pass an id parameter to this route to define which turbo-frame gets updated
  def create
    HelpsMailer.with(name: params[:name],
                     email: params[:email],
                     affiliation: params[:affiliation],
                     help_how: params[:help_how],
                     why_contact: params[:why_contact])
               .jira_email.deliver_later
    respond_to do |format|
      format.turbo_stream
    end
  end
end
