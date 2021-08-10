# frozen_string_literal: true

# This is a patch that ensures the location we want to return to isn't so big as
# to overflow the cookie.
# This is from: https://daniel.fone.net.nz/blog/2014/11/28/actiondispatch-cookies-cookieoverflow-via-devise-s-user-return-to/
# This situation typically occurs when we are scanned for vulnerabilities and a
# CRLF Injection attack is attempted, see https://www.geeksforgeeks.org/crlf-injection-attack/
module SafeStoreLocation
  MAX_LOCATION_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2

  def store_location_for(resource_or_scope, location)
    super unless location && location.size > MAX_LOCATION_SIZE
  end
end

Devise::FailureApp.include SafeStoreLocation
