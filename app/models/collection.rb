# typed: strict
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  has_many :works, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewers, class_name: 'User', join_table: 'reviewers'
  has_and_belongs_to_many :managers, class_name: 'User', join_table: 'managers'

  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true

  sig { returns(T::Boolean) }
  def review_enabled?
    reviewers.present?
  end

  sig { returns(T::Boolean) }
  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  state_machine initial: :first_draft do
    after_transition on: :begin_deposit do |collection, _transition|
      DepositCollectionJob.perform_later(collection)
    end

    event :begin_deposit do
      transition %i[first_draft version_draft deposited] => :depositing
    end

    event :deposit_complete do
      transition depositing: :deposited
    end

    event :update_metadata do
      transition deposited: :version_draft
      transition %i[first_draft version_draft] => same
    end
  end
end
