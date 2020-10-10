# typed: strict
# frozen_string_literal: true

class Work < ApplicationRecord
  belongs_to :collection

  has_many :contributors, dependent: :destroy
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many_attached :files

  state_machine initial: :first_draft do
    event :deposit do
      transition first_draft: :deposited, version_draft: :deposited
    end

    event :new_version do
      transition deposited: :version_draft
    end
  end
end
