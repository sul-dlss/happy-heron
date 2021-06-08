# typed: false
# frozen_string_literal: true

# This creates an appropriate description for an update event on a CollectionVersion
class CollectionVersionEventDescriptionBuilder
  def self.build(form)
    new(form).build
  end

  def initialize(form)
    @form = form
  end

  attr_reader :form

  def build
    [name, description, contact_email, related_links].compact.join(', ')
  end

  def name
    'collection name modified' if form.changed?(:name)
  end

  def description
    'description modified' if form.changed?('description')
  end

  # The has many relationships are showing as changed and that their "id" has changed. I don't know why.
  # So we check for changes in the sub-properties instead
  def contact_email
    'contact email modified' if contact_emails_changed?
  end

  def related_links
    'related links modified' if related_links_changed?
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
