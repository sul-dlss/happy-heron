# typed: strict
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
  validates :created_edtf, :published_edtf, edtf: true
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  state_machine initial: :first_draft do
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

    event :new_version do
      transition deposited: :version_draft
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
end
