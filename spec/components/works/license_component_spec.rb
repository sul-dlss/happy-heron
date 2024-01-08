# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::LicenseComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  context 'when the collection permits selecting a license' do
    context 'with no license selected' do
      let(:work_version) { build(:work_version, license: nil) }

      it 'renders the component' do
        expect(rendered.css('option[selected]')).to be_empty
      end
    end

    context 'with a license selected' do
      let(:work_version) { build(:work_version, license: 'ODbL-1.0') }

      it 'renders the component with the correct license selected' do
        expect(rendered.css('option[selected]')).not_to be_empty
        expect(rendered.to_html).to include('<option selected value="ODbL-1.0">')
      end
    end

    context 'when collection has a default license' do
      let(:collection) { build(:collection, default_license: 'PDDL-1.0') }
      let(:work) { build(:work, collection:) }
      let(:work_version) { build(:work_version, work:, license: nil) }

      it 'renders the component with the collection default' do
        expect(rendered.css('option[selected]')).not_to be_empty
        expect(rendered.to_html).to include('<option selected value="PDDL-1.0">')
      end
    end
  end

  context 'when the collection has a required license' do
    let(:work) { build(:work, collection: build(:collection, :with_required_license)) }

    it 'renders the component' do
      expect(rendered.to_html).to include 'The license for this deposit is CC-BY-4.0 Attribution International.'
    end
  end
end
