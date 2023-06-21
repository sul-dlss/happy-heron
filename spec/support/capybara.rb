# frozen_string_literal: true

require "capybara/cuprite"
require "capybara/rails"
require "capybara/rspec"

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], pending_connection_errors: false)
end

Capybara.disable_animation = true
Capybara.enable_aria_label = true
Capybara.server = :puma, {Silent: true}
Capybara.default_max_wait_time = 10 # default is 2
