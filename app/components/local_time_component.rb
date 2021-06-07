# typed: false
# frozen_string_literal: true

# Draws a custom element for https://github.com/github/time-elements
class LocalTimeComponent < ApplicationComponent
  sig { params(datetime: ActiveSupport::TimeWithZone).void }
  def initialize(datetime:)
    @datetime = datetime
  end

  sig { returns(String) }
  def call
    tag :'local-time', datetime: @datetime.iso8601,
                       month: 'short',
                       day: 'numeric',
                       year: 'numeric',
                       hour: 'numeric',
                       minute: 'numeric',
                       'time-zone-name': 'short'
  end
end
