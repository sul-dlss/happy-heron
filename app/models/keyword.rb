# typed: strict
# frozen_string_literal: true

# Models keywords that describe a work
class Keyword < ApplicationRecord
  belongs_to :work_version
end
