# typed: false
# frozen_string_literal: true

# Base class for all controllers in the application.
class ApplicationController < ActionController::Base
  extend T::Sig

  include DeviseRemoteUser::ControllerBehavior

  # Smartly redirect user back to URL they requested before authenticating
  # From: https://github.com/heartcombo/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  before_action :store_user_location!, if: :storable_location?

  rescue_from ActionPolicy::Unauthorized, with: :deny_access

  sig { returns(T.nilable(User)) }
  def current_user
    super.tap do |cur_user|
      break unless cur_user

      cur_user.groups = ldap_groups
    end
  end

  private

  sig { returns(T::Array[String]) }
  # This looks first in the session for groups, and then to the headers.
  # This allows the application session to outlive the shiboleth session
  def ldap_groups
    session['groups'] ||= begin
      raw_header = request.env[Settings.authorization_group_header]
      raw_header = ENV['ROLES'] if Rails.env.development?
      logger.debug("Roles are #{raw_header}")
      raw_header&.split(';') || []
    end
  end

  def deny_access
    flash[:warning] = 'You are not authorized to perform the requested action'
    redirect_to :root
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController,
  #   or H2's own LoginController, as that could cause an infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  sig { returns(T::Boolean) }
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !is_a?(LoginController) &&
      !request.xhr?
  end

  sig { void }
  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  sig { void }
  def ensure_sdr_updatable
    return if Settings.allow_sdr_content_changes

    flash[:warning] = 'Creating/Updating SDR content (i.e. collections or works) is not yet available.'
    redirect_to :root
  end
end
