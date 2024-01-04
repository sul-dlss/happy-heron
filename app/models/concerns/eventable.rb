# frozen_string_literal: true

# For models that log events
module Eventable
  # Events are logged after state transitions; this allows additional params to be added to the event
  attr_writer :event_context

  def event_context
    @event_context || default_event_context
  end

  private

  def default_event_context; end
end
