# typed: strict
# frozen_string_literal: true

class Work < ApplicationRecord
  has_many :contributors, dependent: :nullify
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many_attached :files
end
