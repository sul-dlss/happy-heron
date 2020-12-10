# typed: strict
# frozen_string_literal: true

# Sends messages about a collection changing state to the CollectionUpdatesChannel
class BroadcastCollectionChange
  extend T::Sig

  sig { params(collection: Collection, state: Symbol).void }
  def self.call(collection:, state:)
    # The only state transition we care about is depositing -> deposited because
    # that's when the UI removes the "depositing" label from the collection.
    # When the collection is in other states, no state label is displayed.
    return unless state == :deposited

    purl_link = "<a href=\"#{collection.purl}\">#{collection.purl}</a>"
    CollectionUpdatesChannel.broadcast_to(collection, state: '', purl: purl_link)
  end
end
