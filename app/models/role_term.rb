# typed: strict
# frozen_string_literal: true

class RoleTerm < ApplicationRecord
  validates :label, presence: true
end
