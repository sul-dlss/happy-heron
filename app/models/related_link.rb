# typed: strict
# frozen_string_literal: true

class RelatedLink < ApplicationRecord
  belongs_to :work

  validates :url, presence: true
end
