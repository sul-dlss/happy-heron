# frozen_string_literal: true

# Models a user of the system
class User < ApplicationRecord
  Warden::Manager.after_set_user except: :fetch do |record, warden, options|
    record.just_signed_in = true if warden.authenticated?(options[:scope])
  end

  attr_accessor :just_signed_in

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

  def to_s
    email
  end

  def sunetid
    email.delete_suffix('@stanford.edu')
  end

  def to_honeybadger_context
    { user_id: id, user_email: email }
  end
end
