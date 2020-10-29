# typed: strict
# frozen_string_literal: true

# Models a citation of a work that is related to the deposited work.
class RelatedWork < ApplicationRecord
  belongs_to :work

  validates :citation, presence: true
end
