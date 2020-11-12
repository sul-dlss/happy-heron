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

  validates :abstract, :access, :state, :title, presence: true
  validates :contact_email, presence: true, format: { with: Devise.email_regexp }
  validates :created_edtf, :published_edtf, edtf: true
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  state_machine initial: :first_draft do
    event :deposit do
      transition first_draft: :deposited, version_draft: :deposited
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
end
