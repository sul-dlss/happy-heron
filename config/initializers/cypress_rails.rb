# frozen_string_literal: true

return unless Rails.env.test?

Rails.application.load_tasks unless defined?(Rake::Task)

CypressRails.hooks.before_server_start do
  # Purge and reload the test database
  Rake::Task["db:test:prepare"].invoke
  Rake::Task["db:seed"].invoke
end

# CypressRails.hooks.after_server_start do
# end

# CypressRails.hooks.after_transaction_start do
# end

# CypressRails.hooks.after_state_reset do
# end

# CypressRails.hooks.before_server_stop do
# end
