# frozen_string_literal: true

# Optional text to display on home page/dashboard, as edited by an Admin user
class PageContent < ApplicationRecord
  validates :value, length: { maximum: 1000 }
  validates :link_text, length: { minimum: 5, maximum: 100 }, if: :link_visible
  validates :link_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), if: :link_visible
end
