# frozen_string_literal: true

# Models a notification sent to a user.
class Notification < ApplicationRecord
  belongs_to :user

  validates :text, presence: true
end
