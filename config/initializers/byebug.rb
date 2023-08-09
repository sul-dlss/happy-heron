# frozen_string_literal: true

return unless Rails.env.development?

debugger = ENV.fetch("REMOTE_DEBUGGER", nil)
# Using `Rails.logger` won't output the messages below to stdout (e.g., as returned from `bin/dev`)
logger = ActiveSupport::Logger.new($stdout)

# byebug is the only remote debugger we support at the moment
return if debugger.blank?

abort("Debugger not supported: #{debugger}") unless debugger == "byebug"

require "byebug/core"
debugger_host = ENV.fetch("DEBUGGER_HOST", "localhost")
debugger_port = ENV.fetch("DEBUGGER_PORT", 8989).to_i

begin
  # Include a useful message in server output
  logger.info("Starting #{debugger}...")
  Byebug.start_server(debugger_host, debugger_port)
  logger.info("You may now connect to #{debugger} via: bundle exec #{debugger} -R #{debugger_host}:#{debugger_port}")
rescue Errno::EADDRINUSE
  abort("#{debugger} already running on #{debugger_host}:#{debugger_port}! Change DEBUGGER_HOST and/or DEBUGGER_PORT and try again.")
end
