# frozen_string_literal: true

# Models an author's affiliations
class Affiliation < ApplicationRecord
  belongs_to :abstract_contributor

  def to_s
    [label, department].compact_blank.join(', ')
  end
end
