# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::WorksComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collections works' do
    let(:collection) { create(:collection, :with_works) }
    let(:user_with_groups) { UserWithGroups.new(user: user, groups: groups) }
    let(:user) { create(:user) }
    let(:groups) { [Settings.authorization_workgroup_names.administrators] }

    before do
      allow(controller).to receive_messages(
        allowed_to?: true,
        current_user: user,
        user_with_groups: user_with_groups
      )
    end

    it 'renders the works detail table component' do
      expect(rendered.css('table').to_html).to include('Test title').exactly(8).times
    end
  end
end
