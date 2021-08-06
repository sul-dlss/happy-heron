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

  describe 'scope' do
    subject(:scope) { policy.apply_scope(Collection, type: :active_record_relation, name: :deposit) }

    let(:policy) { described_class.new context }
    let!(:collection) { create(:collection) }

    context 'when the user is not affiliated' do
      it { is_expected.not_to include(collection) }
    end

    context 'when the user is a manager' do
      let!(:collection) { create(:collection, managed_by: [user]) }

      it { is_expected.to include(collection) }
    end

    context 'when the user is a reviewer' do
      let!(:collection) { create(:collection, reviewed_by: [user]) }

      it { is_expected.to include(collection) }
    end

    context 'when the user is a depositor' do
      let!(:collection) { create(:collection, depositors: [user]) }

      it { is_expected.to include(collection) }
    end
  end

  describe_rule :review? do
    failed 'when user is not a collection creator'

    succeed 'when user is an admin' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }
    end

    failed 'when user is depositor' do
      let(:record) { build_stubbed(:collection, depositors: [user]) }
    end

    succeed 'when user is an reviewer' do
      let(:record) { build_stubbed(:collection, reviewed_by: [user]) }
    end

    succeed 'when user is a manager' do
      let(:record) { build_stubbed(:collection, managed_by: [user]) }
    end
  end
end
