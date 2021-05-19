# typed: false
# frozen_string_literal: true

# Models the deposit of an single version of a digital repository object
class WorkVersion < ApplicationRecord
  class WorkTypeUpdateError < RuntimeError; end
  include AggregateAssociations

  belongs_to :work
  has_many :contributors, dependent: :destroy, class_name: 'Contributor'
  has_many :authors, dependent: :destroy, class_name: 'Author'
  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many :attached_files, dependent: :destroy
  has_many :keywords, dependent: :destroy

  validates :state, presence: true
  validates :license, inclusion: { in: License.license_list(include_displayable: true) }, allow_nil: true
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  scope :awaiting_review_by, lambda { |user|
    with_state(:pending_approval)
      .joins(:work)
      .left_outer_joins(work: { collection: :reviewed_by })
      .left_outer_joins(work: { collection: :managed_by })
      .where('reviewers.user_id = %s OR managers.user_id = %s', user.id, user.id)
  }

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  LINK_TEXT = ':link will be inserted here automatically when available:'

  after_update_commit -> { work.broadcast_update }

  state_machine initial: :new do
    before_transition WorkObserver.method(:before_transition)

    after_transition WorkObserver.method(:after_transition)
    after_transition on: :begin_deposit, do: WorkObserver.method(:after_begin_deposit)
    after_transition on: :reserve_purl, do: WorkObserver.method(:after_begin_deposit)
    after_transition on: :reject, do: WorkObserver.method(:after_rejected)
    after_transition on: :submit_for_review, do: WorkObserver.method(:after_submit_for_review)
    after_transition on: :deposit_complete, do: WorkObserver.method(:after_deposit_complete)
    after_transition on: :deposit_complete, do: CollectionObserver.method(:item_deposited)

    # Trigger the collection observer when starting a new draft,
    # except when the previous state was draft.
    after_transition except_from: :first_draft, to: :first_draft,
                     do: CollectionObserver.method(:first_draft_created)
    after_transition except_from: :version_draft, to: :version_draft,
                     do: CollectionObserver.method(:version_draft_created)

    # NOTE: there is no approval "event" because when a work is approved in review, it goes
    # directly to begin_deposit event, which will transition it to depositing
    event :begin_deposit do
      transition %i[first_draft version_draft pending_approval] => :depositing
    end

    event :deposit_complete do
      transition depositing: :deposited
    end

    event :pid_assigned do
      transition reserving_purl: :purl_reserved
      transition depositing: same
    end

    event :submit_for_review do
      transition %i[first_draft version_draft rejected] => :pending_approval
      transition pending_approval: same
    end

    event :reject do
      transition pending_approval: :rejected
    end

    event :reserve_purl do
      transition new: :reserving_purl
    end

    event :update_metadata do
      transition new: :first_draft

      transition %i[first_draft version_draft pending_approval rejected] => same
      transition purl_reserved: :version_draft
    end
  end

  def updatable?
    can_update_metadata? || deposited?
  end

  def draft?
    version_draft? || first_draft?
  end

  sig { void }
  def add_purl_to_citation
    return unless citation

    update!(citation: T.must(citation).gsub(LINK_TEXT, T.must(work.purl)))
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

  sig { returns(T::Boolean) }
  def purl_reservation?
    work_type == WorkType.purl_reservation_type.id
  end

  sig { params(work_type: String, subtype: T::Array[String], modifier: User).void }
  def choose_type_for_purl_reservation(work_type, subtype, modifier)
    raise WorkTypeUpdateError, 'Cannot update Work Version type, no longer PURL reservation' unless purl_reservation?

    self.work_type = work_type
    self.subtype = subtype
    work.events.create(user: modifier, event_type: 'type_selected')
    transaction do
      save!
      update_metadata!
    end
  end
end
