# frozen_string_literal: true

# Models a version of a collection in the database
class CollectionVersion < ApplicationRecord
  include AggregateAssociations

  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  belongs_to :collection, touch: true

  strip_attributes allow_empty: true, only: [:name, :description]

  after_update_commit -> { collection.broadcast_update }

  include CollectionVersionStateMachine

  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  def updatable?
    can_update_metadata? || (deposited? && head?)
  end

  def draft?
    version_draft? || first_draft?
  end

  def head?
    collection.head == self
  end
end
