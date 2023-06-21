# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectionDecommissionPolicy do
  let(:user) { build_stubbed(:user) }
  # `record` must be defined - it is the authorization target
  let(:record) { build_stubbed(:collection) }
  # `context` is the authorization context
  let(:context) do
    {
      user:,
      user_with_groups: UserWithGroups.new(user:, groups:)
    }
  end
  let(:groups) { [] }

  describe_rule :update? do
    failed "when user is not an adminstrator"

    succeed "when user is an admin" do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end
  end
end
