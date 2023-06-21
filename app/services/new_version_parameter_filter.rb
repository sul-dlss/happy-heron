# frozen_string_literal: true

# Updates the passed in parameters so they create new related objects rather than point at objects for a past version
class NewVersionParameterFilter
  # @param [ActionController::Parameters] clean_params these parameters will be mutated by this filter
  # @param [WorkVersion] old_version
  def self.call(clean_params, old_version)
    filter_attached_files(clean_params, old_version)

    associations_to_filter.each do |relation|
      filter_relation_params(clean_params, old_version, relation)
    end
  end

  # Update the attached_files parameters so that we create new attached files
  # that point at the same Blobs
  # rubocop:disable Metrics/AbcSize
  def self.filter_attached_files(clean_params, old_version)
    return if clean_params[:attached_files_attributes].blank?

    old_version.attached_files.each do |existing|
      existing_params = clean_params[:attached_files_attributes].values.find { |hash| hash["id"] == existing.id.to_s }
      next if existing_params.blank?

      existing_params["file"] = existing.file_attachment.blob.signed_id
      existing_params.delete("id")
    end
  end
  # rubocop:enable Metrics/AbcSize
  private_class_method :filter_attached_files

  def self.filter_relation_params(clean_params, old_version, relation)
    old_version.public_send(relation).each do |existing|
      existing_params = clean_params["#{relation}_attributes"].values.find { |hash| hash["id"] == existing.id.to_s }
      next if existing_params.blank?

      existing_params.delete("id")
    end
  end
  private_class_method :filter_relation_params

  def self.associations_to_filter
    WorkVersion.aggregate_associations - [:attached_files]
  end
  private_class_method :associations_to_filter
end
