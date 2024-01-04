# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::WorksComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection:)) }

  context 'when displaying a collections works' do
    let(:collection) { create(:collection) }
    let(:user_with_groups) { UserWithGroups.new(user:, groups:) }
    let(:user) { create(:user) }
    let(:work1) { create(:work, collection:, depositor: user) }
    let(:work2) { create(:work, collection:) }
    let(:work_version1) { create(:work_version, work: work1) }
    let(:work_version2) { create(:work_version, work: work2) }

    before do
      work1.update(head: work_version1)
      work2.update(head: work_version2)

      allow(controller).to receive_messages(
        current_user: user,
        user_with_groups:
      )
    end

    context 'when administrator' do
      let(:groups) { [Settings.authorization_workgroup_names.administrators] }

      it 'renders the works detail table component' do
        expect(rendered.css('table').to_html).to include('Test title').exactly(8).times
        expect(rendered.to_html).to include('data-datatable-works-hide-depositor-value="false"')
      end
    end

    context 'when depositor' do
      let(:groups) { [] }

      it 'renders the works detail table component' do
        expect(rendered.to_html).to include('data-datatable-works-hide-depositor-value="true"')
      end
    end
  end
end
