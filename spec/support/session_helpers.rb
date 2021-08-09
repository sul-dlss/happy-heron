# frozen_string_literal: true

module SessionHelpers
  include Warden::Test::Helpers

  def sign_in(user = nil, groups: [])
    TestShibbolethHeaders.user = user.email
    TestShibbolethHeaders.groups = groups
  end

  def sign_out
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
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :feature
  config.include SessionHelpers, type: :request
end
