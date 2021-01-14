# typed: false
# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  include Eventable

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'

  has_many :contributors, dependent: :destroy
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

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  state_machine initial: :new do
    before_transition do |work, transition|
      work.events.build(work.event_context.merge(event_type: transition.event))
    end

    after_transition on: :begin_deposit do |work, _transition|
      DepositJob.perform_later(work)
    end

    after_transition except_from: :first_draft, to: :first_draft, do: CollectionObserver.method(:collection_activity)
    after_transition except_from: :version_draft, to: :version_draft,
                     do: CollectionObserver.method(:collection_activity)

    after_transition on: :deposit_complete do |work, _transition|
      mailer = WorksMailer.with(user: work.depositor, work: work)
      job = if work.collection.review_enabled?
              mailer.approved_email
            elsif work.version > 1
              mailer.new_version_deposited_email
            else
              mailer.deposited_email
            end
      job.deliver_later
    end

    after_transition do |work, transition|
      BroadcastWorkChange.call(work: work, state: transition.to_name)
    end

    after_transition on: :reject do |work, _transition|
      WorksMailer.with(user: work.depositor, work: work)
                 .reject_email.deliver_later
    end

    after_transition on: :submit_for_review do |work, _transition|
      (work.collection.reviewers + work.collection.managers - [work.depositor]).each do |recipient|
        ReviewersMailer.with(user: recipient, work: work).submitted_email.deliver_later
      end
      WorksMailer.with(user: work.depositor, work: work).submitted_email.deliver_later
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
