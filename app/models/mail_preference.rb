# frozen_string_literal: true

# Represents the users preference to receive mail for collection actions
class MailPreference < ApplicationRecord
  MANAGER_TYPES = %w[
    participant_changed
    new_item
    submit_for_review
    version_started_but_not_finished
    decommissioned
    assigned_new_owner
    item_deleted
  ].freeze

  REVIEWER_TYPES = %w[
    new_item
    submit_for_review
  ].freeze

  # Orders the results the same way the TYPES array is ordered
  default_scope do
    first_letters = MANAGER_TYPES.map(&:first).join
    a_byte = 'a'.bytes.first
    replace_with = (a_byte..a_byte + MANAGER_TYPES.size - 1).to_a.pack('c*') # rubocop:disable Lint/AmbiguousRange
    order(Arel.sql("translate(email, '#{first_letters}', '#{replace_with}')"))
  end
  belongs_to :user
  belongs_to :collection
  validates :email, uniqueness: { scope: %i[user_id collection_id] },
                    inclusion: { in: MANAGER_TYPES }

  def self.complete_manager_set?(preferences)
    preferences.size == MANAGER_TYPES.size
  end

  def self.complete_reviewer_set?(preferences)
    preferences.pluck(:email).sort == REVIEWER_TYPES
  end
end
