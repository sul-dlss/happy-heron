# frozen_string_literal: true

# Draws a custom element for https://github.com/github/time-elements
class LocalTimeComponent < ApplicationComponent
  def initialize(datetime:)
    @datetime = datetime
  end

  def call
    tag.local_time(datetime: @datetime.iso8601,
                   month: 'short',
                   day: 'numeric',
                   year: 'numeric',
                   hour: 'numeric',
                   minute: 'numeric',
                   'time-zone-name': 'short')
  end
end
