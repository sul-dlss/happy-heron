# typed: strict
# frozen_string_literal: true

# Models an email in the database
class ContactEmail < ApplicationRecord
  belongs_to :emailable, polymorphic: true
end
