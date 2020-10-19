# typed: strict
# frozen_string_literal: true

class Work < ApplicationRecord
  belongs_to :collection

  has_many :contributors, dependent: :destroy
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many_attached :files

  validates :abstract, presence: true
  validates :access, presence: true
  validates :citation, presence: true
  validates :contact_email, presence: true
  validates :created_edtf, presence: true
  validates :license, presence: true
  validates :state, presence: true
  validates :subtype, presence: true
  validates :title, presence: true
  validates :work_type, presence: true

  state_machine initial: :first_draft do
    event :deposit do
      transition first_draft: :deposited, version_draft: :deposited
    end

    event :new_version do
      transition deposited: :version_draft
    end
  end
end
