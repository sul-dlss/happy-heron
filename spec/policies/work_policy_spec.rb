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

    failed 'when user is a depositor and status is pending_approval' do
      let(:record) { build_stubbed :work, :pending_approval, depositor: user }
    end

    failed 'when user is a depositor and status is depositing' do
      let(:record) { build_stubbed :work, :depositing, depositor: user }
    end

    succeed 'when user is an admin and status is not pending_approval' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    succeed 'when user is a collection manager and status is not pending_approval' do
      let(:collection) { build_stubbed :collection, managers: [user] }
    end

    succeed 'when user is a collection reviewer and status is not pending_approval' do
      let(:collection) { build_stubbed :collection, reviewers: [user] }
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

  describe 'scope' do
    subject(:scope) { policy.apply_scope(collection.works, type: :active_record_relation, name: :edits) }

    let(:policy) { described_class.new context }
    let(:collection) { create(:collection) }
    let(:work) { create(:work, collection: collection) }

    context 'when the user is not affiliated' do
      it { is_expected.to be_empty }
    end

    context 'when the user is the depositor' do
      let(:user) { create(:user) }
      let(:work) { create(:work, collection: collection, depositor: user) }

      it { is_expected.to include(work) }
    end

    context 'when the user is a reviewer' do
      let(:collection) { create(:collection, reviewers: [user]) }

      it { is_expected.to include(work) }
    end

    context 'when the user is a manager' do
      let(:collection) { create(:collection, managers: [user]) }

      it { is_expected.to include(work) }
    end
  end
end
