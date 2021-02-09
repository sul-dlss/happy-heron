# typed: false
# frozen_string_literal: true

class Version < ApplicationRecord
  belongs_to :versionable, polymorphic: true
end
