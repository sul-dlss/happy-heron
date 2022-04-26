# frozen_string_literal: true

# Base class for all controllers in the application.
class ApplicationController < ActionController::Base
  include DeviseRemoteUser::ControllerBehavior

  before_action :add_honeybadger_context
  # Smartly redirect user back to URL they requested before authenticating
  # From: https://github.com/heartcombo/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  before_action :store_user_location!, if: :storable_location?
  before_action :copy_just_signed_in_to_session

  rescue_from ActionPolicy::Unauthorized, with: :deny_access

  authorize :user_with_groups

  def user_with_groups
    UserWithGroups.new(user: current_user, groups: ldap_groups) if current_user
  end
  helper_method :user_with_groups

  private

  def add_honeybadger_context
    Honeybadger.context(current_user)
  end

  # If User#just_signed_in is set, copy that into the session
  def copy_just_signed_in_to_session
    session[:just_signed_in] = current_user.just_signed_in if current_user&.just_signed_in
  end

  # This looks first in the session for groups, and then to the headers.
  # This allows the application session to outlive the shiboleth session
  def ldap_groups
    session['groups'].presence || groups_from_request_env
  end

  # Get the groups from the headers and store them in the session
  def groups_from_request_env
    session['groups'] = begin
      raw_header = request.env[Settings.authorization_group_header]
      raw_header = ENV.fetch('ROLES', nil) if Rails.env.development? # rubocop:disable Rails/EnvironmentVariableAccess
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

  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !is_a?(LoginController) &&
      !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  MAX_LOCATION_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2

  # This overrides devise so that we always check that we have enough space in the cookie
  # to store the full location.
  # This is adapted from: https://daniel.fone.net.nz/blog/2014/11/28/actiondispatch-cookies-cookieoverflow-via-devise-s-user-return-to/
  # This situation typically occurs when we are scanned for vulnerabilities and a
  # CRLF Injection attack is attempted, see https://www.geeksforgeeks.org/crlf-injection-attack/
  def store_location_for(resource_or_scope, location)
    super unless location && location.size > MAX_LOCATION_SIZE
  end

  def ensure_sdr_updatable
    return if Settings.allow_sdr_content_changes

    flash[:warning] = 'Creating/Updating SDR content (i.e. collections or works) is not yet available.'
    redirect_to :root
  end
end
