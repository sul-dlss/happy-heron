# frozen_string_literal: true

# Models a user of the system
class User < ApplicationRecord
  Warden::Manager.after_set_user except: :fetch do |record, warden, options|
    record.just_signed_in = true if warden.authenticated?(options[:scope])
  end

  attr_accessor :just_signed_in

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              allow_blank: true # because the presence validation is the only error we want to show.
            }

  has_many :notifications, dependent: :destroy
  has_many :owned_works, class_name: 'Work',
                         foreign_key: 'owner_id',
                         inverse_of: :owner,
                         dependent: :destroy

  has_and_belongs_to_many :reviews_collections, class_name: 'Collection', join_table: 'reviewers'
  has_and_belongs_to_many :manages_collections, class_name: 'Collection', join_table: 'managers'
  has_and_belongs_to_many :deposits_into, class_name: 'Collection', join_table: 'depositors'

  devise :remote_user_authenticatable

  # this is the timeframe after which the user must agree to the terms again on a work
  def terms_agreement_renewal_timeframe
    Time.zone.now.years_ago(1)
  end

  def to_s
    email
  end

  def sunetid
    email.delete_suffix('@stanford.edu')
  end

  def to_honeybadger_context
    { user_id: id, user_email: email }
  end

  def agreed_to_terms_recently?
    return false if last_work_terms_agreement.nil?

    terms_agreement_renewal_timeframe < last_work_terms_agreement
  end
end
