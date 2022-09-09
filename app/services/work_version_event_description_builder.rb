# frozen_string_literal: true

# This creates an appropriate description for an update event on a WorkVersion
class WorkVersionEventDescriptionBuilder
  def self.build(form)
    new(form).build
  end

  def initialize(form)
    @form = form
  end

  attr_reader :form

  def build # rubocop:disable Metrics/AbcSize
    [
      title, abstract, contact_email, authors, contributors, related_links,
      related_works, publication_date, created_date, keywords, subtype,
      citation, embargo, access, license, files, file_visibility, file_description,
      assign_doi
    ].compact.join(', ')
  end

  def collection
    @collection ||= form.model[:work].collection
  end

  def title
    'title of deposit modified' if form.changed?('title')
  end

  def abstract
    'abstract modified' if form.changed?('abstract')
  end

  def authors
    'authors modified' if form.changed?('authors')
  end

  def contributors
    'contributors modified' if form.changed?('contributors')
  end

  # The has many relationships are showing as changed and that their "id" has changed. I don't know why.
  # So we check for changes in the sub-properties instead
  def contact_email
    'contact email modified' if form.changed?('contact_emails')
  end

  def related_links
    'related links modified' if form.changed?('related_links')
  end

  def publication_date
    'publication date modified' if form.changed?('published_edtf')
  end

  def created_date
    'creation date modified' if form.changed?('created_edtf')
  end

  def keywords
    'keywords modified' if form.changed?('keywords')
  end

  def subtype
    'work subtypes modified' if form.changed?('subtype')
  end

  def access
    'visibility modified' if access_changed?
  end

  def access_changed?
    return false unless collection.access == 'depositor-selects'

    form.changed?('access')
  end

  def citation
    'citation modified' if citation_changed?
  end

  def citation_changed?
    return false if form.input_params['default_citation'] == 'true'

    form.changed?('citation')
  end

  def embargo
    'embargo modified' if embargo_changed?
  end

  def embargo_changed?
    return false if %w[delay immediate].include?(collection.release_option)

    form.changed?('embargo_date')
  end

  def license
    'license modified' if license_changed?
  end

  def license_changed?
    return false if collection.required_license

    form.changed?('license')
  end

  def files
    return unless form.input_params

    attributes = form.input_params[:attached_files_attributes]
    return unless attributes

    # We can't check for changes resulting from a remove on the attached_files since they're already gone.
    destroyed = attributes.values.any? { |params| params['_destroy'] == '1' }

    # we don't want description changes to cause an "added new file" message
    added = form.attached_files.any? { |af| af.changed?('_destroy') }

    return unless added || destroyed

    'files added/removed'
  end

  def file_visibility
    'file visibility changed' if form.attached_files.any? { |af| af.changed?('hide') }
  end

  def file_description
    'file description changed' if form.attached_files.any? { |af| af.changed?('label') && af.label.present? }
  end

  def related_works
    'related works modified' if form.changed?('related_works')
  end

  def assign_doi
    'assign DOI modified' if form.changed?('assign_doi')
  end
end
