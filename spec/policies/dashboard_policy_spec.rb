# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardPolicy do
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

  describe_rule :show? do
    failed "when user is not an admin, collection creator, depositor or reviewer"

    succeed "when user is an admin" do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    succeed "when user is a collection creator" do
      let(:groups) { [Settings.authorization_workgroup_names.collection_creators] }
    end

    succeed "when user is a reviewer" do
      let(:user) { create(:collection, :with_reviewers, reviewer_count: 1).reviewed_by.first }
    end

    succeed "when user is a manager" do
      let(:user) { create(:collection, :with_managers, manager_count: 1).managed_by.first }
    end

    succeed "when user is a depositor" do
      let(:user) { create(:collection, :with_depositors, depositor_count: 1).depositors.first }
    end
  end
end
