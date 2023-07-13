# frozen_string_literal: true

# Models a citation of a work that is related to the deposited work.
class RelatedWork < ApplicationRecord
  belongs_to :work_version
  validates :citation, presence: true
  strip_attributes allow_empty: true, only: [:citation]
end
