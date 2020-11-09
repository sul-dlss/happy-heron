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
      user_with_groups: UserWithGroups.new(user: user, groups: [])
    }
  end

  describe_rule :create? do
    failed 'when user is neither a depositor or manager for the collection'

    # `succeed` is `context` + `specify`, which checks
    # that the result of application wasn't successful
    succeed 'when user is a depositor' do
      before { collection.depositors = [user] }
    end

    succeed 'when user is a collection manager' do
      before { collection.managers = [user.sunetid] }
    end
  end
end
