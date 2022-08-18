# frozen_string_literal: true

require 'capybara/cuprite'
require 'capybara/rails'
require 'capybara/rspec'

class FerrumLogger
  attr_reader :logs

  def initialize
    @logs = []
  end

  # Filter out the noise - I believe Runtime.exceptionThrown and Log.entryAdded are the interesting log methods but there might be others you need
  def puts(log_str)
    _log_symbol, _log_time, log_body_str = log_str.strip.split(' ', 3)
    
    return if log_body_str.nil?
    
    log_body = JSON.parse(log_body_str)

    case log_body['method']
    when "Runtime.consoleAPICalled"
      log_body["params"]["args"].each do |arg|
        Kernel.puts arg["value"]
      end
    when "Runtime.exceptionThrown", "Log.entryAdded"
      Kernel.puts "#{log_body["params"]["entry"]["url"]} - #{log_body["params"]["entry"]["text"]}"
    end
  end

  def truncate
    @logs = []
  end
end

Capybara.javascript_driver = :cuprite
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], pending_connection_errors: false, logger: FerrumLogger.new)
end

Capybara.disable_animation = true
Capybara.enable_aria_label = true
Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 10 # default is 2
