# typed: true
# frozen_string_literal: true

# For models that log events
module Eventable
  extend T::Sig
  extend T::Helpers

  abstract!

  # Events are logged after state transitions; this allows additional params to be added to the event
  sig { params(event_context: T::Hash[Symbol, String]).returns(T::Hash[Symbol, String]) }
  attr_writer :event_context

  sig { returns(T::Hash[Symbol, String]) }
  def event_context
    @event_context || default_event_context
  end

  private

  sig { abstract.returns(T::Hash[Symbol, String]) }
  def default_event_context; end
end
