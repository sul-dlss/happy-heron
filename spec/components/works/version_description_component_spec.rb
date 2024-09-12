# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::VersionDescriptionComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  context 'with a first draft' do
    let(:work_version) { build(:work_version, work:) }

    it 'does not render the component' do
      expect(rendered.to_html).not_to include('Version your work')
    end
  end

  context 'with a deposited work' do
    let(:work_version) { build(:work_version, work:, state: 'deposited') }

    it 'renders the component' do
      expect(rendered.to_html).to include('Version your work')
    end
  end

  context 'with a rejected work' do
    let(:work_version) { build(:work_version, work:, state: 'rejected') }

    it 'does not render the component' do
      expect(rendered.to_html).not_to include('Version your work')
    end
  end

  context 'with a rejected work that has been accessioned' do
    let(:work_version) { build(:work_version, work:, version: 2, state: 'rejected') }

    it 'renders the component' do
      expect(rendered.to_html).to include('Version your work')
    end
  end

  context 'when user version feature flag is on' do
    let(:work_version) { build(:work_version, work:, state: 'deposited') }

    before do
      allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
    end

    it 'renders the user version selection' do
      expect(rendered.to_html).to include('Do you want to create a new version of this deposit?')
      expect(rendered.to_html).not_to include('Version your work')
    end

    context 'with a pending_approval work' do
      let(:work_version) { build(:work_version, work:, state: 'pending_approval') }

      it 'does not render the component' do
        expect(rendered.to_html).not_to include('Do you want to create a new version of this deposit?')
      end
    end

    context 'with a pending_approval work that has been accessioned' do
      let(:work_version) { build(:work_version, work:, version: 2, state: 'pending_approval') }

      it 'renders the component' do
        expect(rendered.to_html).to include('Do you want to create a new version of this deposit?')
      end
    end

    context 'with a rejected work' do
      let(:work_version) { build(:work_version, work:, state: 'rejected') }

      it 'does not render the component' do
        expect(rendered.to_html).not_to include('Do you want to create a new version of this deposit?')
      end
    end

    context 'with user versions and a rejected work that has been accessioned' do
      let(:work_version) { build(:work_version, work:, version: 2, state: 'rejected') }

      it 'renders the component' do
        expect(rendered.to_html).to include('Do you want to create a new version of this deposit?')
      end
    end
  end
end
