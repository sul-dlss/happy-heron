# frozen_string_literal: true

# This creates an appropriate description for a create/update event on a WorkVersion
class WorkVersionEventDescriptionBuilder
  def self.build(form)
    new(form).build
  end

  def initialize(form)
    @form = form
  end

  attr_reader :form

  def build # rubocop:disable Metrics/AbcSize
    changes = [
      title, abstract, contact_email, authors, contributors, related_links,
      related_works, publication_date, created_date, keywords, subtype,
      citation, embargo, access, license, custom_rights, files, file_visibility,
      file_description, assign_doi
    ].compact.join(", ")

    # if this is a new work and there are no changes, return "Created", else return changes
    if new_work? && changes.blank?
      "Created"
    else
      changes
    end
  end

  private

  # indicates if this is a new work (work version is in the "new" state on v1)
  def new_work?
    form.model[:work_version].new? && form.model[:work_version].version == 1
  end

  # if the user removes a field from an association (e.g. keyword), reform does not indicate this as a change
  # ... so instead we will count the number in the form and in the model, and if different, it has changed
  def changed_amount?(field_name)
    form.send(field_name).size != form.work_version.send(field_name).size
  end

  def collection
    @collection ||= form.model[:work].collection
  end

  def custom_rights
    "custom terms modified" if form.changed?("custom_rights")
  end

  def title
    "title of deposit modified" if form.changed?("title")
  end

  def abstract
    "abstract modified" if form.changed?("abstract")
  end

  def authors
    "authors modified" if form.changed?("authors") || changed_amount?("authors")
  end

  def contributors
    "contributors modified" if form.changed?("contributors") || changed_amount?("contributors")
  end

  # The has many relationships are showing as changed and that their "id" has changed. I don't know why.
  # So we check for changes in the sub-properties instead
  def contact_email
    "contact email modified" if form.changed?("contact_emails") || changed_amount?("contact_emails")
  end

  def related_links
    "related links modified" if form.changed?("related_links") || changed_amount?("related_links")
  end

  def publication_date
    "publication date modified" if form.changed?("published_edtf")
  end

  def created_date
    "creation date modified" if form.changed?("created_edtf")
  end

  def keywords
    "keywords modified" if form.changed?("keywords") || changed_amount?("keywords")
  end

  def subtype
    "work subtypes modified" if subtype_changed?
  end

  def subtype_changed?
    # do not report subtype changes on a work creation, since they are required and always "change" on a new work
    return false if new_work?

    form.changed?("subtype") || changed_amount?("subtype")
  end

  def access
    "visibility modified" if access_changed?
  end

  def access_changed?
    return false unless collection.access == "depositor-selects"

    form.changed?("access")
  end

  def citation
    "citation modified" if citation_changed?
  end

  def citation_changed?
    return false if form.input_params["default_citation"] == "true"

    form.changed?("citation")
  end

  def embargo
    "embargo modified" if embargo_changed?
  end

  def embargo_changed?
    return false if %w[delay immediate].include?(collection.release_option)

    form.changed?("embargo_date")
  end

  def license
    "license modified" if license_changed?
  end

  def license_changed?
    return false if collection.required_license

    # do not report license changes on a work creation if they are the default license
    return false if new_work? && collection.default_license == form.license

    form.changed?("license")
  end

  def files
    return unless form.input_params

    attributes = form.input_params[:attached_files_attributes]
    return unless attributes

    # We can't check for changes resulting from a remove on the attached_files since they're already gone.
    destroyed = attributes.values.any? { |params| params["_destroy"] == "1" }

    # we don't want description changes to cause an "added new file" message
    added = form.attached_files.any? { |af| af.changed?("_destroy") }

    return unless added || destroyed

    "files added/removed"
  end

  def file_visibility
    "file visibility changed" if form.attached_files.any? { |af| af.changed?("hide") }
  end

  def file_description
    "file description changed" if form.attached_files.any? do |af|
                                    (af.changed?("label") && af.label.present?) ||
                                      (af.changed?("label") && af.id.present?)
                                  end
  end

  def related_works
    "related works modified" if form.changed?("related_works") || changed_amount?("related_works")
  end

  def assign_doi
    "assign DOI modified" if form.changed?("assign_doi")
  end
end
