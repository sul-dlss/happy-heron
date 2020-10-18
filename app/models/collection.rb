# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'
end
