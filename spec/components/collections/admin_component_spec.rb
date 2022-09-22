# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::AdminComponent, type: :component do
  let(:collection_version) { build_stubbed(:collection_version_with_collection, state:) }
  let(:instance) { described_class.new(collection: collection_version.collection) }
  let(:groups) { [] }
  let(:rendered) { render_inline(instance) }
  let(:state) { 'deposited' }
  let(:user) { build(:user, name: 'Pyotr Kropotkin', email: 'kropot00@stanford.edu') }
  let(:user_with_groups) { UserWithGroups.new(user:, groups:) }

  before do
    allow(controller).to receive_messages(
      current_user: user,
      user_with_groups:
    )
    allow(collection_version.collection).to receive(:head).and_return(collection_version)
  end

  context 'with a non-admin user' do
    it 'does not render' do
      expect(rendered.to_html).to be_empty
    end
  end

  context 'with an admin user' do
    let(:groups) { [Settings.authorization_workgroup_names.administrators] }

    context 'with head in a state other than decommissioned' do
      it 'includes an option to decommission' do
        expect(rendered.to_html).to include('Decommission collection')
      end
    end

    context 'with head in a decommissioned state' do
      let(:state) { 'decommissioned' }

      it 'does not include an option to decommission' do
        expect(rendered.to_html).not_to include('Decommission collection')
      end
    end
  end
end
