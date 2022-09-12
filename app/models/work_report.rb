# frozen_string_literal: true

# Model for a work report
class WorkReport
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :state
  attribute :collection_id, :integer
  attribute :date_created_start, :date
  attribute :date_created_end, :date
  attribute :date_modified_start, :date
  attribute :date_modified_end, :date
end
