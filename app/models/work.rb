class Work < ApplicationRecord
  has_many :contributors
  has_many :related_links
  has_many :related_works
end
