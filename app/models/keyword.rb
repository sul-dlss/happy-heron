# frozen_string_literal: true

# Models keywords that describe a work
class Keyword < ApplicationRecord
  belongs_to :work_version
  strip_attributes allow_empty: true, only: %i[uri label]
end
