# typed: true
# frozen_string_literal: true

# Filters the passed in parameters so they create new objects rather than point at objects for a past version
class NewVersionParameterFilter
  def self.call(clean_params, old_version)
    filter_attached_files(clean_params, old_version)

    associations_to_filter.each do |relation|
      filter_relation_params(clean_params, old_version, relation)
    end
  end

  # Update the attached_files parameters so that we create new attached files
  # that point at the same Blobs
  def self.filter_attached_files(clean_params, old_version)
    old_version.attached_files.each do |existing|
      existing_params = clean_params[:attached_files_attributes].values.find { |hash| hash['id'] == existing.id.to_s }
      existing_params['file'] = existing.file_attachment.blob.signed_id
      existing_params.delete('id')
    end
  end
  private_class_method :filter_attached_files

  def self.filter_relation_params(clean_params, old_version, relation)
    old_version.public_send(relation).each do |existing|
      existing_params = clean_params["#{relation}_attributes"].values.find { |hash| hash['id'] == existing.id.to_s }
      existing_params.delete('id')
    end
  end
  private_class_method :filter_relation_params

  def self.associations_to_filter
    WorkVersion.aggregate_associations - [:attached_files]
  end
  private_class_method :associations_to_filter
end
