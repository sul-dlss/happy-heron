# frozen_string_literal: true

class Work < ApplicationRecord
  has_many :contributors
  has_many :related_links
  has_many :related_works
  has_many_attached :files
end
