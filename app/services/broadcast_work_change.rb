# typed: true
# frozen_string_literal: true

# Sends messages about a work changing state to the WorkUpdatesChannel
class BroadcastWorkChange
  extend T::Sig

  sig { params(work: Work, state: Symbol).void }
  def self.call(work:, state:)
    display = Works::StateDisplayComponent.new(work: work).call
    case state
    when :deposited
      purl_link = "<a href=\"#{work.purl}\">#{work.purl}</a>"
      WorkUpdatesChannel.broadcast_to(work, state: display, purl: purl_link)
    else
      WorkUpdatesChannel.broadcast_to(work, state: display)
    end
  end
end
