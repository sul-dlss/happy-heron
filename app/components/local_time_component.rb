# frozen_string_literal: true

# Draws a custom element for https://github.com/github/time-elements
class LocalTimeComponent < ApplicationComponent
  def initialize(datetime:, show_time: true)
    @datetime = datetime
    @show_time = show_time
  end

  def call
    options = {datetime: @datetime.iso8601, month: "short", day: "numeric", year: "numeric"}
    options.merge!(hour: "numeric", minute: "numeric", "time-zone-name": "short") if @show_time
    tag.local_time(**options)
  end
end
