# frozen_string_literal: true

# Model for a sunetid report
class SunetidReport
  include ActiveModel::API
  include ActiveModel::Attributes

  attribute :druids, array: true, default: []
end
