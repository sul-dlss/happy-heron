# frozen_string_literal: true

# Models an email in the database
class ContactEmail < ApplicationRecord
  belongs_to :emailable, polymorphic: true
  strip_attributes allow_empty: true, only: [:email]
end
