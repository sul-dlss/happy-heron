# frozen_string_literal: true

# The endpoint for the help modal
class HelpsController < ApplicationController
  def new
    @email = current_user&.email
    @help_how_value = if params[:show_collections] == 'true'
                        'Request access to another collection'
                      elsif !current_user
                        'I want to become an SDR depositor'
                      end
  end

  # You can pass an id parameter to this route to define which turbo-frame gets updated
  # rubocop:disable Metrics/AbcSize
  def create
    HelpsMailer.with(name: params[:name],
                     email: params[:email],
                     affiliation: params[:affiliation],
                     help_how: params[:help_how],
                     why_contact: params[:why_contact],
                     collections: params[:collections])
               .jira_email.deliver_later
    respond_to do |format|
      format.turbo_stream
    end
  end
  # rubocop:enable Metrics/AbcSize
end
