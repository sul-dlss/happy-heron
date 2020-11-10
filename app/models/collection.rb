# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewers, class_name: 'User', join_table: 'reviewers'

  validates :contact_email, presence: true, format: { with: Devise.email_regexp }
  validates :description, presence: true
  validates :managers, presence: true
  validates :name, presence: true
  validates :access, presence: true
end
