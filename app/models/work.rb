# typed: true
# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  extend T::Sig

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'

  has_many :contributors, dependent: :destroy
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many :attached_files, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true
  validates :state, presence: true
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  # Events are logged after state transitions, if the description or user is set, it will be added to the event
  sig { params(event_context: T::Hash[Symbol, String]).returns(T::Hash[Symbol, String]) }
  attr_writer :event_context

  sig { returns(T::Hash[Symbol, String]) }
  def event_context
    @event_context || { user: depositor }
  end

  state_machine initial: :first_draft do
    before_transition do |work, transition|
      work.events.build(work.event_context.merge(event_type: transition.to))
    end

    after_transition on: :begin_deposit do |work, _transition|
      DepositJob.perform_later(work)
    end

    after_transition do |work, transition|
      BroadcastWorkChange.call(work: work, state: transition.to_name)
    end

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
      transition %i[first_draft version_draft rejected] => same
    end
  end

  sig { returns(T.nilable(String)) }
  def name
    title.presence || 'No title'
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
  end

  sig { void }
  def add_purl_to_citation
    return unless citation

    self.citation = T.must(citation).gsub(/:link:/, T.must(purl))
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

  def published_edtf
    EDTF.parse(super)
  end

  def created_edtf
    EDTF.parse(super)
  end

  # This ensures that action-policy doesn't think that every 'Work.new' is the same.
  # This supports the following:
  #   allowed_to :create?, Work.new(collection:collection)
  def policy_cache_key
    persisted? ? cache_key : object_id
  end
end
