# frozen_string_literal: true

# Draws a custom element for https://github.com/github/relative-time-element
class LocalTimeComponent < ApplicationComponent
  def initialize(datetime:, show_time: true)
    @datetime = datetime
    @show_time = show_time
  end

  def call
    options = { datetime: @datetime.iso8601, format: 'datetime', weekday: '', month: 'short', year: 'numeric' }
    options.merge!(second: '2-digit', hour: '2-digit', minute: '2-digit', timeZoneName: 'short') if @show_time
    tag.relative_time(**options)
  end
end
