# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkPolicy do
  let(:user) { build_stubbed :user }
  # `record` must be defined - it is the authorization target
  let(:record) { build_stubbed :work, collection: collection }
  let(:collection) { build_stubbed :collection }

  # `context` is the authorization context
  let(:context) do
    {
      user: user,
      user_with_groups: UserWithGroups.new(user: user, groups: groups)
    }
  end

  let(:groups) { [] }

  describe_rule :create? do
    failed 'when user is neither a depositor or manager for the collection'

    # `succeed` is `context` + `specify`, which checks
    # that the result of application wasn't successful
    succeed 'when user is a depositor' do
      before { collection.depositors = [user] }
    end

    failed 'when user is a depositor but the collection is depositing' do
      let(:collection) { build_stubbed :collection, state: 'depositing' }

      before { collection.depositors = [user] }
    end

    succeed 'when user is a collection manager' do
      before { collection.managers = [user] }
    end

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end
  end

  describe_rule :update? do
    failed 'when user is not the depositor'

    succeed 'when user is the depositor and status is not pending_approval' do
      let(:record) { build_stubbed :work, depositor: user }
    end

    failed 'when user is the depositor and status is pending_approval' do
      let(:record) { build_stubbed :work, :pending_approval, depositor: user }
    end

    succeed 'when user is an admin and status is not pending_approval' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    failed 'when user is an admin and status is pending_approval' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
      let(:record) { build_stubbed :work, :pending_approval }
    end
  end

  describe_rule :review? do
    failed 'when user is not a reviewer the collection' do
      let(:record) { build_stubbed :work, :pending_approval, collection: collection }
    end

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
      let(:record) { build_stubbed :work, :pending_approval, collection: collection }
    end

    succeed 'when user is a reviewer and status is pending_approval' do
      let(:record) { build_stubbed :work, :pending_approval, collection: collection }
      before { collection.reviewers = [user] }
    end

    failed 'when user is a reviewer and status is not pending_approval' do
      before { collection.reviewers = [user] }
    end

    failed 'when user is an admin and status is not pending_approval' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end
  end
end
