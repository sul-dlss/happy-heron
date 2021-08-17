# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkPolicy do
  let(:user) { build_stubbed :user }
  # `record` must be defined - it is the authorization target
  let(:work_version) { build_stubbed :work_version, work: work }
  let(:work) { build_stubbed :work, collection: collection }
  let(:collection) { build_stubbed :collection, head: collection_version }
  let(:collection_version) { build_stubbed :collection_version, :deposited }
  let(:record) { work }

  # `context` is the authorization context
  let(:context) do
    {
      user: user,
      user_with_groups: UserWithGroups.new(user: user, groups: groups)
    }
  end

  let(:groups) { [] }

  before { work.head = work_version }

  describe_rule :destroy? do
    context 'when persisted and deletable' do
      failed 'when user is not a depositor, reviewer or manager for the collection'

      # `succeed` is `context` + `specify`, which checks
      # that the result of application wasn't successful
      succeed 'when user is a depositor' do
        before { record.depositor = user }
      end

      succeed 'when user is a collection manager' do
        before { collection.managed_by = [user] }
      end

      succeed 'when user is a reviewer' do
        before { collection.reviewed_by = [user] }
      end

      succeed 'when user is an admin' do
        let(:groups) { [Settings.authorization_workgroup_names.administrators] }
      end
    end

    context 'when deposited (and thus not deletable)' do
      before { work_version.state = 'deposited' }

      failed 'when user is neither a depositor, reviewer or manager for the collection'

      failed 'when user is a depositor' do
        before { record.depositor = user }
      end

      failed 'when user is a collection manager' do
        before { collection.managed_by = [user] }
      end

      failed 'when user is a reviewer' do
        before { collection.reviewed_by = [user] }
      end

      failed 'when user is an admin' do
        let(:groups) { [Settings.authorization_workgroup_names.administrators] }
      end
    end

    context 'when not persisted' do
      let(:work) { Work.new(attributes_for(:work).merge(collection: collection)) }

      failed 'when user is not a depositor, reviewer or manager for the collection'

      failed 'when user is a depositor' do
        before { record.depositor = user }
      end

      failed 'when user is a collection manager' do
        before { collection.managed_by = [user] }
      end

      failed 'when user is a reviewer' do
        before { collection.reviewed_by = [user] }
      end

      failed 'when user is an admin' do
        let(:groups) { [Settings.authorization_workgroup_names.administrators] }
      end
    end
  end
end
