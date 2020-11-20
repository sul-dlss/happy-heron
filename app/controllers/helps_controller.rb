# typed: false
# frozen_string_literal: true

# The endpoint for the help modal
class HelpsController < ApplicationController
  def create
    name = params[:name]
    email = params[:email]
    affiliation = params[:affiliation]
    help_how = params[:help_how]
    why_contact = params[:why_contact]
    body = "#{name} #{affiliation}\n#{why_contact}"

    HelpsMailer.new.send_jira(email, help_how, body)
    render json: { status: 'success' }
  end
end
