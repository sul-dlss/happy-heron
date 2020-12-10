# typed: strict
# frozen_string_literal: true

# An ActionCable channel for sending updates about collections
class CollectionUpdatesChannel < ApplicationCable::Channel
  extend T::Sig

  sig { returns(T.any(Concurrent::ThreadPoolExecutor, T::Array[String])) }
  def subscribed
    stream_for Collection.find(params[:id])
  end

  sig { returns(T::Array[T.untyped]) }
  def unsubscribed
    stop_all_streams
  end
end
