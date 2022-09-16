# frozen_string_literal: true

# This creates an appropriate description for an update event on a Collection
class CollectionEventDescriptionBuilder
  def self.build(form:, change_set:)
    new(form:, change_set:).build
  end

  def initialize(form:, change_set:)
    @form = form
    @change_set = change_set
  end

  attr_reader :form, :change_set

  def build
    [participants, release_settings, download_settings, doi_settings, license_settings, notification_settings,
     review_settings].compact.join(', ')
  end

  private

  def participants
    change_set.participant_change_description if change_set.participants_changed?
  end

  def release_settings
    'release settings modified' if release_settings_changed?
  end

  def download_settings
    'download setting modified' if download_settings_changed?
  end

  def doi_settings
    'DOI setting modified' if doi_settings_changed?
  end

  def license_settings
    'license settings modified' if license_settings_changed?
  end

  def notification_settings
    'notification settings modified' if notification_settings_changed?
  end

  def review_settings
    'review workflow settings modified' if review_settings_changed?
  end

  def release_settings_changed?
    form.changed?(:release_option) || form.changed?(:release_duration)
  end

  def download_settings_changed?
    form.changed?(:access)
  end

  def doi_settings_changed?
    form.changed?(:doi_option)
  end

  def license_settings_changed?
    form.changed?(:license_option) || form.changed?(:default_license) || form.changed?(:required_license)
  end

  def notification_settings_changed?
    # Form does not correctly track changes.
    change_set.email_depositors_status_changed_changed? || change_set.email_when_participants_changed_changed?
  end

  def review_settings_changed?
    # Form does not correctly track changes.
    change_set.review_enabled_changed? || change_set.reviewers_changed?
  end
end
