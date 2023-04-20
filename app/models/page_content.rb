# frozen_string_literal: true

# Optional text to display on home page/dashboard, as edited by an Admin user
class PageContent < ApplicationRecord
  validates :value, length: { maximum: 30 }
end
