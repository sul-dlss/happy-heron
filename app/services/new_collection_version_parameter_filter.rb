# typed: true
# frozen_string_literal: true

# Filters the passed in parameters so they create new objects rather than point at objects for a past version
# TODO: there is lots of duplicate code here from NewVersionParameterFilter
class NewCollectionVersionParameterFilter
  def self.call(clean_params, old_version)
    associations_to_filter.each do |relation|
      filter_relation_params(clean_params, old_version, relation)
    end
  end

  def self.filter_relation_params(clean_params, old_version, relation)
    old_version.public_send(relation).each do |existing|
      existing_params = clean_params["#{relation}_attributes"].values.find { |hash| hash['id'] == existing.id.to_s }
      existing_params.delete('id')
    end
  end
  private_class_method :filter_relation_params

  def self.associations_to_filter
    CollectionVersion.aggregate_associations - [:attached_files]
  end
  private_class_method :associations_to_filter
end
