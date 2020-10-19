# typed: strict
# frozen_string_literal: true

class RelatedWork < ApplicationRecord
  belongs_to :work

  validates :citation, presence: true
end
