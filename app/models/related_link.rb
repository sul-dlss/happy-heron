# typed: strict
# frozen_string_literal: true

# Models a URI that is related to a work
class RelatedLink < ApplicationRecord
  belongs_to :work

  validates :url, presence: true
end
