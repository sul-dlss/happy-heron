# frozen_string_literal: true

# Completes the deposit of an object
class DepositCompleter
  def self.complete(object_version:)
    new(object_version:).complete
  end

  attr_reader :object_version

  def initialize(object_version:)
    @object_version = object_version
  end

  def complete
    # No-op unless object version is in a state that can transition to `deposit_complete`
    return unless object_version&.can_deposit_complete?

    parent.event_context = {
      user: sdr_user,
      description: "What changed: #{what_changed}"
    }

    object_version.deposit_complete!
  end

  def parent
    # Though object and object.head.collection/object.head.work are the same in DB, they are not the same in memory.
    # Thus, need to set event_context on the traversed parent object.
    object_version.try(:collection) || object_version.work
  end

  private

  def sdr_user
    User.find_by!(name: 'SDR')
  end

  def what_changed
    object_version.version_description.presence || 'not specified'
  end
end
