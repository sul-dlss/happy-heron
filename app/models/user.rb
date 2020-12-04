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
  has_and_belongs_to_many :manages_collections, class_name: 'Collection', join_table: 'managers'
  has_and_belongs_to_many :deposits_into, class_name: 'Collection', join_table: 'depositors'

  devise :remote_user_authenticatable

  sig { returns(String) }
  def to_s
    email
  end

  sig { returns(String) }
  def sunetid
    email.delete_suffix('@stanford.edu')
  end

  sig { returns(String) }
  # TODO: replace when doing https://github.com/sul-dlss/happy-heron/issues/671
  def name
    '[preferred name in directory]'
  end
end
