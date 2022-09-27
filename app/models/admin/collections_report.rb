# frozen_string_literal: true

module Admin
  # Model for an admin collections report
  class CollectionsReport
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :status_deposited, :boolean, default: false
    attribute :status_first_draft, :boolean, default: false
    attribute :status_version_draft, :boolean, default: false
    attribute :status_decommissioned, :boolean, default: false
    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date

    def statuses
      [].tap do |statuses|
        statuses << 'deposited' if status_deposited
        statuses << 'first_draft' if status_first_draft
        statuses << 'version_draft' if status_version_draft
        statuses << 'decommissioned' if status_decommissioned
      end
    end
  end
end
