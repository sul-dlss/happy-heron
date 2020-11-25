# typed: false
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

  state_machine initial: :first_draft do
    after_transition deposited: :version_draft do |work, _transition|
      Event.create!(work: work, user: work.depositor, event_type: 'new_version')
      display = Works::StateDisplayComponent.new(work: work).call
      WorkUpdatesChannel.broadcast_to(work, state: display)
    end

    after_transition on: :deposit_complete do |work, _transition|
      Event.create!(work: work, user: work.depositor, event_type: 'deposit_complete')
      display = Works::StateDisplayComponent.new(work: work).call
      purl_link = "<a href=\"#{work.purl}\">#{work.purl}</a>"
      WorkUpdatesChannel.broadcast_to(work, state: display, purl: purl_link)
    end

    after_transition on: :submit_for_review do |work, _transition|
      Event.create!(work: work, user: work.depositor, event_type: 'submit_for_review')
      display = Works::StateDisplayComponent.new(work: work).call
      WorkUpdatesChannel.broadcast_to(work, state: display)
    end

    after_transition on: :begin_deposit do |work, _transition|
      Event.create!(work: work, user: work.depositor, event_type: 'begin_deposit')
      display = Works::StateDisplayComponent.new(work: work).call
      WorkUpdatesChannel.broadcast_to(work, state: display)
      DepositJob.perform_later(work)
    end

    after_transition on: :reject do |work, _transition|
      display = Works::StateDisplayComponent.new(work: work).call
      WorkUpdatesChannel.broadcast_to(work, state: display)
    end

    event :begin_deposit do
      transition first_draft: :depositing, version_draft: :depositing, pending_approval: :depositing
    end

    event :deposit_complete do
      transition depositing: :deposited
    end

    event :submit_for_review do
      transition first_draft: :pending_approval
    end

    event :reject do
      transition pending_approval: :first_draft
    end

    event :update_metadata do
      transition deposited: :version_draft
      transition %i[first_draft version_draft] => same
    end
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
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
end
