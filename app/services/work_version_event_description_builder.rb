# typed: false
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
      citation, embargo, access, license, files, file_visibility, file_description
    ].compact.join(', ')
  end

  def title
    'title of deposit modified' if form.changed?(:title)
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
    'contact email modified' if contact_emails_changed?
  end

  def related_links
    'related links modified' if related_links_changed?
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
    'visibility modified' if form.changed?('access')
  end

  def citation
    'citation modified' if form.changed?('citation')
  end

  def embargo
    'embargo modified' if form.changed?('release') || form.changed?('embargo_date')
  end

  def license
    'license modified' if form.changed?('license')
  end

  def files
    'files added/removed' if form.changed?('attached_files')
  end

  def file_visibility
    'file visibility changed' if form.attached_files.any? { |af| af.changed?('hide') }
  end

  def file_description
    'file description changed' if form.attached_files.any? { |af| af.changed?('label') }
  end

  def related_works
    'related works modified' if form.changed?('related_works')
  end

  # The has many relationships are showing as changed and that their "id" has changed. I don't know why.
  # So we check for changes in the sub-properties instead
  def contact_emails_changed?
    form.contact_emails.any? { |email| email.changed?(:email) }
  end

  # The has many relationships are showing as changed and that their "id" has changed. I don't know why.
  # So we check for changes in the sub-properties instead
  def related_links_changed?
    form.related_links.any? do |link|
      link.changed?(:link_title) || link.changed?(:url)
    end
  end
end
