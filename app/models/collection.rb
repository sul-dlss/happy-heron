# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'

  validates :contact_email, presence: true
  validates :description, presence: true
  validates :managers, presence: true
  validates :name, presence: true
  validates :access, presence: true
end
