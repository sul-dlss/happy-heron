# typed: strict
# frozen_string_literal: true

# Models an email in the database
class ContactEmail < ApplicationRecord
  belongs_to :emailable, polymorphic: true

  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
end
