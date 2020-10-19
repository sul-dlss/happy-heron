# typed: strict
# frozen_string_literal: true

class Contributor < ApplicationRecord
  belongs_to :work
  belongs_to :role_term

  validates :first_name, presence: true
  validates :last_name, presence: true
end
