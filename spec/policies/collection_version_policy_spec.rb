# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionVersionPolicy do
  let(:user) { build_stubbed :user }
  # # `record` must be defined - it is the authorization target
  let(:record) { build_stubbed :collection_version, collection: collection }
  let(:collection) { build_stubbed :collection }

  # `context` is the authorization context
  let(:context) do
    {
      user: user,
      user_with_groups: UserWithGroups.new(user: user, groups: groups)
    }
  end
  let(:groups) { [] }

  describe_rule :update? do
    # `succeed` is `context` + `specify`, which checks
    # that the result of application wasn't successful
    failed 'when user is a depositor' do
      let(:collection) { build_stubbed(:collection, depositors: [user]) }
    end

    succeed 'when user is a collection manager' do
      let(:collection) { build_stubbed(:collection, managed_by: [user]) }
    end

    failed 'when user is a collection manager and status is depositing' do
      let(:collection) { build_stubbed :collection, managed_by: [user] }
      let(:record) { build_stubbed :collection_version, :depositing, collection: collection }
    end

    failed 'when the collection version is not the head version' do
      let(:collection) { build_stubbed :collection, managed_by: [user], head: build_stubbed(:collection_version) }
      let(:record) { build_stubbed :collection_version, :deposited, collection: collection }
    end

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end
  end

  describe_rule :show? do
    failed 'when user is not allowed to view the collection'

    succeed 'when the user is a depositor to the collection' do
      let(:collection) { build_stubbed(:collection, depositors: [user]) }
    end

    succeed 'when the user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    succeed 'when the user manages the collection' do
      let(:collection) { build_stubbed(:collection, managed_by: [user]) }
    end

    succeed 'when the user is a collection reviewer' do
      let(:collection) { build_stubbed(:collection, reviewed_by: [user]) }
    end
  end
end
