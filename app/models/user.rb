# typed: strict
# frozen_string_literal: true

# Models a user of the system
class User < ApplicationRecord
  extend T::Sig

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }

  has_many :notifications, dependent: :destroy
  has_many :deposits, class_name: 'Work',
                      foreign_key: 'depositor_id',
                      inverse_of: :depositor,
                      dependent: :destroy

  has_and_belongs_to_many :reviews_collections, class_name: 'Collection', join_table: 'reviewers'

  devise :remote_user_authenticatable

  sig { returns(String) }
  def to_s
    email
  end

  sig { returns(String) }
  def sunetid
    email.delete_suffix('@stanford.edu')
  end
end
