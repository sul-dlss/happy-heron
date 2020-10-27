# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'

  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :description, presence: true
  validates :managers, presence: true
  validates :name, presence: true
  validates :access, presence: true
end
