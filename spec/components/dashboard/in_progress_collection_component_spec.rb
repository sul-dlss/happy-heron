# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressCollectionComponent, type: :component do
  let(:presenter) do
    instance_double(DashboardPresenter, collection_managers_in_progress: collections)
  end
  let(:user_with_groups) { UserWithGroups.new(user: user, groups: []) }
  let(:user) { create(:user) }
  let(:rendered) { render_inline(described_class.new(presenter: presenter)) }

  before do
    allow(controller).to receive_messages(
      current_user: user,
      user_with_groups: user_with_groups
    )
    create(:collection)
    create(:collection)
    create(:collection)
  end

  context 'when presenter has zero in progress collections' do
    let(:collections) { Collection.none }

    it 'does not render the component at all' do
      expect(rendered.to_html).not_to include('Collections in progress')
    end
  end

  context 'when presenter has one or more in progress collections' do
    let(:collections) { Collection.all }

    it 'renders the component with collections' do
      expect(rendered.to_html).to include('Collections in progress')
      collections.pluck(:name).each do |name|
        expect(rendered.to_html).to include(name)
      end
    end
  end
end
