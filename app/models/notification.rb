# typed: strict
# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user

  validates :text, presence: true
end
