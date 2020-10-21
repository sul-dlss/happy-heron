# typed: strict
# frozen_string_literal: true

class Work < ApplicationRecord
  belongs_to :collection

  has_many :contributors, dependent: :destroy
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many_attached :files

  validates :abstract, :access, :citation, :contact_email, :state,
            :subtype, :title, presence: true
  validates :created_edtf, presence: true, edtf: true
  validates :license, presence: true, inclusion: { in: License.all.map(&:id) }
  validates :work_type, presence: true, inclusion: { in: WorkType.all.map(&:id) }

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  state_machine initial: :first_draft do
    event :deposit do
      transition first_draft: :deposited, version_draft: :deposited
    end

    event :new_version do
      transition deposited: :version_draft
    end
  end
end
