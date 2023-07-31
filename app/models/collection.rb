# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  include Eventable

  has_many :works, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_many :collection_versions, dependent: :destroy
  has_many :mail_preferences, dependent: :destroy

  validates :doi_option, inclusion: {in: %w[depositor-selects no yes]}

  belongs_to :creator, class_name: "User"
  belongs_to :head, class_name: "CollectionVersion", optional: true
  has_and_belongs_to_many :depositors, class_name: "User", join_table: "depositors"
  has_and_belongs_to_many :reviewed_by, class_name: "User", join_table: "reviewers"
  has_and_belongs_to_many :managed_by, class_name: "User", join_table: "managers"

  EMBARGO_RELEASE_DURATION_OPTIONS = {"6 months from date of deposit": "6 months",
                                      "1 year from date of deposit": "1 year",
                                      "2 years from date of deposit": "2 years",
                                      "3 years from date of deposit": "3 years"}.freeze
  def broadcast_update
    # Update the collection settings show page. This changes the header from
    # saying "depositing" and appends to the history.
    broadcast_replace_to self, :settings

    # Update the collection details show page. This reveals the PURL when it is
    # added and changes the header from saying "depositing".
    broadcast_replace_to self, :details, partial: "collection_versions/collection_version",
      locals: {collection_version: head}

    # This will update the summary of the collection on the dashboard including the
    # status and the buttons.
    broadcast_replace_to :summary,
      target: ActionView::RecordIdentifier.dom_id(self, :summary),
      partial: "dashboards/collection_without_user"
  end

  def release_date
    return nil if release_duration.nil?
    return Time.zone.today + 6.months if release_duration == "6 months"

    Time.zone.today + release_duration.gsub(/[^\d]/, "").to_i.years
  end

  # The collection has allowed the user to specify availablity on the member works

  def user_can_set_availability?
    release_option == "depositor-selects"
  end

  # The collection has allowed the user to select a license for the member works

  def user_can_set_license?
    license_option == "depositor-selects"
  end

  def purl
    return nil unless druid

    File.join(Settings.purl_url, druid_without_namespace)
  end

  def druid_without_namespace
    druid&.delete_prefix("druid:")
  end

  def works_without_decommissioned
    works.joins(:head).where.not(head: {state: "decommissioned"})
  end

  def opted_out_of_email?(user, email)
    mail_preferences.where(user:, email:, wanted: false).any?
  end

  # This builds any missing mail preference
  def mail_preferences_for_user(user)
    return manager_mail_preferences_for_user(user) if managed_by.include?(user)

    reviewer_mail_preferences_for_user(user)
  end

  def allow_custom_rights_statement?
    allow_custom_rights_statement
  end

  def custom_rights_statement_source_option
    return nil unless allow_custom_rights_statement?

    if provided_custom_rights_statement.present?
      "provided_by_collection"
    else
      "entered_by_depositor"
    end
  end

  def custom_rights_instructions_source_option
    return nil unless allow_custom_rights_statement?

    if custom_rights_statement_custom_instructions.present?
      "provided_by_collection"
    else
      "default_instructions"
    end
  end

  def effective_custom_rights_instructions
    unless custom_rights_statement_source_option == "entered_by_depositor"
      raise "Custom rights for collection id #{id} not entered by depositor; thus it doesn't make sense to determine instructions for entering"
    end

    if custom_rights_instructions_source_option == "provided_by_collection"
      custom_rights_statement_custom_instructions
    else
      I18n.t("collection.depositor_custom_rights_instructions")
    end
  end

  private

  def default_event_context
    {user: creator}
  end

  def manager_mail_preferences_for_user(user)
    preferences = mail_preferences.where(user:)
    return preferences if MailPreference.complete_manager_set?(preferences) # all preferences accounted for

    build_email_preferences(user, MailPreference::MANAGER_TYPES, preferences.map(&:email))
  end

  def reviewer_mail_preferences_for_user(user)
    preferences = mail_preferences.where(user:)
    return preferences if MailPreference.complete_reviewer_set?(preferences) # all preferences accounted for

    build_email_preferences(user, MailPreference::REVIEWER_TYPES, preferences.map(&:email))
  end

  def build_email_preferences(user, emails_to_build, existing_emails)
    MailPreference.transaction do
      (emails_to_build - existing_emails).each do |email|
        MailPreference.create!(user:, collection: self, email:)
      end
    end
    mail_preferences.where(user:)
  end
end
