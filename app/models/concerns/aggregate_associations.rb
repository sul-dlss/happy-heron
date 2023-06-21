# frozen_string_literal: true

# Provides a helper method for associations
module AggregateAssociations
  extend ActiveSupport::Concern

  class_methods do
    # Which associations are has_many?
    # Used when creating parameter filters in NewVersionParameterFilter and NewCollectionVersionParameterFilter
    def aggregate_associations
      reflections.values
        .select { |ref| ref.is_a?(ActiveRecord::Reflection::HasManyReflection) }
        .map(&:name)
    end
  end
end
