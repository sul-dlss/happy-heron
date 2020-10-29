# typed: true
# frozen_string_literal: true

# This is a Rack middleware that we use in testing. It injects headers
# that simulate mod_shib so we can test.
# This is certainly not thread safe as it uses class level variables
class TestShibbolethHeaders
  class_attribute :user, :groups

  def initialize(app)
    @app = app
  end

  def call(env)
    env['REMOTE_USER'] = user
    env['eduPersonEntitlement'] = groups.join(';') if groups.present? # allow omission of header for testing
    @app.call(env)
  end
end
