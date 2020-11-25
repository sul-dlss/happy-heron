# typed: false
# frozen_string_literal: true

# Sends messages about a work changing state to the WorkUpdatesChannel
class BroadcastStateChange
  def self.call(work:)
    display = Works::StateDisplayComponent.new(work: work).call
    WorkUpdatesChannel.broadcast_to(work, state: display)
  end

  def self.with_purl(work:)
    display = Works::StateDisplayComponent.new(work: work).call
    purl_link = "<a href=\"#{work.purl}\">#{work.purl}</a>"
    WorkUpdatesChannel.broadcast_to(work, state: display, purl: purl_link)
  end
end
