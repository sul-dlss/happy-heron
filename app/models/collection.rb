# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewers, class_name: 'User', join_table: 'reviewers'

  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true

  sig { returns(T::Boolean) }
  def review_enabled?
    reviewers.present?
  end
end
