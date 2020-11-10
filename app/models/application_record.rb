# typed: strict
# frozen_string_literal: true

# The base class of all database models
class ApplicationRecord < ActiveRecord::Base
  extend T::Sig

  self.abstract_class = true
end
