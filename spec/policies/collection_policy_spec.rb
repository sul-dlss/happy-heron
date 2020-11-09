# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionPolicy do
  let(:user) { build_stubbed :user }
  # `record` must be defined - it is the authorization target
  let(:record) { build_stubbed :collection }

  # `context` is the authorization context
  let(:context) do
    {
      user: user,
      user_with_groups: UserWithGroups.new(user: user, groups: groups)
    }
  end
  let(:groups) { [] }

  describe_rule :create? do
    failed 'when user is not a collection creator'

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    succeed 'when user is a collection creator' do
      let(:groups) { [Settings.authorization_workgroup_names.collection_creators] }
    end
  end

  describe_rule :update? do
    # `succeed` is `context` + `specify`, which checks
    # that the result of application wasn't successful
    failed 'when user is a depositor' do
      let(:record) { build_stubbed(:collection, depositors: [user]) }
    end

    succeed 'when user is a collection manager' do
      let(:record) { build_stubbed(:collection, managers: [user.sunetid]) }
    end

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end
  end
end
