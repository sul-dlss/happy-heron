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
      description:
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
    "What changed: #{object_version.version_description.presence || 'not specified'}"
  end

  def description
    return what_changed unless object_version.is_a?(WorkVersion)
    return what_changed unless Settings.user_versions_ui_enabled

    return what_changed unless object_version.new_user_version?

    "Version #{object_version.user_version} created. #{what_changed}"
  end
end
