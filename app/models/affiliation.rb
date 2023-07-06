# frozen_string_literal: true

# Models an author's affiliations
class Affiliation < ApplicationRecord
  belongs_to :abstract_contributor
end
