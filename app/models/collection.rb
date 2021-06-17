# typed: false
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  include Eventable

  has_many :works, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_many :collection_versions, dependent: :destroy

  belongs_to :creator, class_name: 'User'
  belongs_to :head, class_name: 'CollectionVersion', optional: true
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewed_by, class_name: 'User', join_table: 'reviewers'
  has_and_belongs_to_many :managed_by, class_name: 'User', join_table: 'managers'

  EMBARGO_RELEASE_DURATION_OPTIONS = { '6 months from date of deposit': '6 months',
                                       '1 year from date of deposit': '1 year',
                                       '2 years from date of deposit': '2 years',
                                       '3 years from date of deposit': '3 years' }.freeze
  def broadcast_update
    # Update the collection settings show page. This changes the header from
    # saying "depositing" and appends to the history.
    broadcast_replace_to self, :settings

    # Update the collection details show page. This reveals the PURL when it is
    # added and changes the header from saying "depositing".
    broadcast_replace_to self, :details, partial: 'collection_versions/collection_version',
                                         locals: { collection_version: head }

    # This will update the summary of the collection on the dashboard including the
    # status and the buttons.
    broadcast_replace_to :summary,
                         target: ActionView::RecordIdentifier.dom_id(self, :summary),
                         partial: 'dashboards/collection_without_user'
  end

  sig { returns(T.nilable(Date)) }
  def release_date
    return nil if release_duration.nil?
    return Time.zone.today + 6.months if release_duration == '6 months'

    Time.zone.today + release_duration.gsub(/[^\d]/, '').to_i.years
  end

  # The collection has allowed the user to specify availablity on the member works
  sig { returns(T::Boolean) }
  def user_can_set_availability?
    release_option == 'depositor-selects'
  end

  # The collection has allowed the user to select a license for the member works
  sig { returns(T::Boolean) }
  def user_can_set_license?
    license_option == 'depositor-selects'
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
  end

  private

  sig { override.returns(T::Hash[Symbol, String]) }
  def default_event_context
    { user: creator }
  end
end
