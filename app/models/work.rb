# typed: false
# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  include Eventable

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'

  has_many :contributors, dependent: :destroy, class_name: 'Contributor'
  has_many :authors, dependent: :destroy, class_name: 'Author'
  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many :attached_files, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy

  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :state, presence: true
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  after_update_commit -> { broadcast_replace_to self }
  after_update_commit -> { collection.broadcast_update_collection_summary }

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  LINK_TEXT = ':link will be inserted here automatically when available:'

  state_machine initial: :new do
    before_transition WorkObserver.method(:before_transition)

    after_transition WorkObserver.method(:after_transition)
    after_transition on: :begin_deposit, do: WorkObserver.method(:after_begin_deposit)
    after_transition on: :reject, do: WorkObserver.method(:after_rejected)
    after_transition on: :submit_for_review, do: WorkObserver.method(:after_submit_for_review)
    after_transition on: :deposit_complete, do: WorkObserver.method(:after_deposit_complete)
    after_transition on: :deposit_complete, do: CollectionObserver.method(:collection_activity)

    # Trigger the collection observer when starting a new draft,
    # except when the previous state was draft.
    after_transition except_from: :first_draft, to: :first_draft, do: CollectionObserver.method(:collection_activity)
    after_transition except_from: :version_draft, to: :version_draft,
                     do: CollectionObserver.method(:collection_activity)

    # NOTE: there is no approval "event" because when a work is approved in review, it goes
    # directly to begin_deposit event, which will transition it to depositing
    event :begin_deposit do
      transition %i[first_draft version_draft pending_approval] => :depositing
    end

    event :deposit_complete do
      transition depositing: :deposited
    end

    event :submit_for_review do
      transition %i[first_draft version_draft rejected] => :pending_approval
    end

    event :reject do
      transition pending_approval: :rejected
    end

    event :update_metadata do
      transition deposited: :version_draft
      transition new: :first_draft

      transition %i[first_draft version_draft rejected] => same
    end
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
  end

  sig { void }
  def add_purl_to_citation
    return unless citation

    self.citation = T.must(citation).gsub(LINK_TEXT, T.must(purl))
  end

  sig { params(edtf: T.nilable(T.any(EDTF::Interval, Date))).void }
  # Ensure that EDTF dates get an EDTF serialization
  def created_edtf=(edtf)
    case edtf
    when nil, EDTF::Interval
      super
    when Date
      super(edtf.to_edtf)
    end
  end

  sig { params(edtf: T.nilable(T.any(EDTF::Interval, Date))).void }
  # Ensure that EDTF dates get an EDTF serialization
  def published_edtf=(edtf)
    case edtf
    when nil, EDTF::Interval
      super
    when Date
      super(edtf.to_edtf)
    end
  end

  sig { returns(T.nilable(T.any(EDTF::Interval, Date))) }
  def published_edtf
    EDTF.parse(super)
  end

  sig { returns(T.nilable(T.any(EDTF::Interval, Date))) }
  def created_edtf
    EDTF.parse(super)
  end

  # This ensures that action-policy doesn't think that every 'Work.new' is the same.
  # This supports the following:
  #   allowed_to :create?, Work.new(collection:collection)
  sig { returns(T.any(String, Integer)) }
  def policy_cache_key
    persisted? ? cache_key : object_id
  end

  sig { returns(T.nilable(String)) }
  def last_rejection_description
    events.latest_by_type('reject')&.description
  end

  delegate :name, to: :collection, prefix: true
  delegate :name, to: :depositor, prefix: true

  private

  sig { override.returns(T::Hash[Symbol, String]) }
  def default_event_context
    { user: depositor }
  end
end
