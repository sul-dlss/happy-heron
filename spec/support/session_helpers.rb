# frozen_string_literal: true

module SessionHelpers
  include Warden::Test::Helpers

  def sign_in(user = nil, groups: [])
    clear_cookies
    TestShibbolethHeaders.user = user.email
    TestShibbolethHeaders.groups = groups
  end

  def sign_out
    clear_cookies
    TestShibbolethHeaders.user = nil
    TestShibbolethHeaders.groups = []
  end

  def add_to_session(hash)
    Warden.on_next_request do |proxy|
      hash.each do |key, value|
        proxy.raw_session[key] = value
      end
    end
  end

  def clear_cookies
    # Test for page because this is only relevant to Capybara tests
    # Test for clear_cookies, because the Rack Driver doesn't have that.
    page.driver.clear_cookies if respond_to?(:page) && page.driver.respond_to?(:clear_cookies)
  end
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :feature
  config.include SessionHelpers, type: :request
end
