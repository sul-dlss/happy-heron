# typed: false
# frozen_string_literal: true

class AttachedFile < ApplicationRecord
  belongs_to :work
  has_one_attached :file
end
