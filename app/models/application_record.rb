# typed: strict
# frozen_string_literal: true

# The base class of all database models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
