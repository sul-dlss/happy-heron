# frozen_string_literal: true

if defined?(DatabaseCleaner)
  # cleaning the database using database_cleaner
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
else
  # Manual cleaning
  true
end

CypressOnRails::SmartFactoryWrapper.reload

# if defined?(VCR)
#   VCR.eject_cassette # make sure we no cassette inserted before the next test starts
#   VCR.turn_off!
#   WebMock.disable! if defined?(WebMock)
# end

Rails.logger.info 'APPCLEANED' # used by log_fail.rb
