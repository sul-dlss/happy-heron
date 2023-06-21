# frozen_string_literal: true

# Manual cleaning
# This removes the druid. Druid has a unique constraint that prevents the use of factorybot to create
# collections with the same druid.
Collection.update_all(druid: nil)

CypressOnRails::SmartFactoryWrapper.reload

# if defined?(VCR)
#   VCR.eject_cassette # make sure we no cassette inserted before the next test starts
#   VCR.turn_off!
#   WebMock.disable! if defined?(WebMock)
# end

Rails.logger.info "APPCLEANED" # used by log_fail.rb
