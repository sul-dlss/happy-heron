# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressCollectionComponent, type: :component do
  let(:presenter) do
    instance_double(DashboardPresenter, collection_managers_in_progress: collection_versions)
  end
  let(:user_with_groups) { UserWithGroups.new(user:, groups: []) }
  let(:user) { create(:user) }
  let(:rendered) { render_inline(described_class.new(presenter:)) }

  before do
    allow(vc_test_controller).to receive_messages(
      current_user: user,
      user_with_groups:
    )
  end

  context 'when presenter has zero in progress collections' do
    let(:collection_versions) { CollectionVersion.none }

    it 'does not render the component at all' do
      expect(rendered.to_html).not_to include('Collections in progress')
    end
  end

  context 'when presenter has one or more in progress collections' do
    before do
      create(:collection_version_with_collection)
      create(:collection_version_with_collection)
      create(:collection_version_with_collection)
    end

    let(:collection_versions) { CollectionVersion.all }

    it 'renders the component with collections' do
      expect(rendered.to_html).to include('Collections in progress')
      collection_versions.pluck(:name).each do |name|
        expect(rendered.to_html).to include(name)
      end
    end
  end
end
