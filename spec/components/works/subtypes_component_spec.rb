# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::SubtypesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new('work', work_form, controller.view_context, {}) }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work: work_version.work, work_version: work_version) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  context 'when work type is "other"' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'other', subtype: ['femur']) }

    it 'does not label subtypes as optional' do
      expect(rendered.to_html).to include('Work subtypes *')
      expect(rendered.to_html).to include('Specify "Other" type')
      expect(rendered.css('a[data-bs-content^="Enter a word or short phrase to describe"]')).to be_present
    end
  end

  context 'when work type is "music"' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'music', subtype: ['Data']) }

    it 'does not label subtypes as optional' do
      expect(rendered.to_html).to include('Work subtypes *')
      expect(rendered.css('a[data-bs-content^="You must select at least one term from the shorter list"]'))
        .to be_present
    end

    it 'renders a header about selecting one or more terms' do
      expect(rendered.to_html).to include('Select at least one term below')
    end
  end

  context 'when work type is "mixed material"' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'mixed material', subtype: %w[Data Sound]) }

    it 'does not label subtypes as optional' do
      expect(rendered.to_html).to include('Work subtypes *')
      expect(rendered.css('a[data-bs-content^="You must choose at least two of the terms below"]'))
        .to be_present
    end

    it 'renders a header about selecting two or more terms' do
      expect(rendered.to_html).to include('Select at least two terms below')
    end
  end

  context 'when work type is anything else' do
    it 'does not label subtypes as required' do
      expect(rendered.to_html).to include('Work subtypes')
      expect(rendered.css('a[data-bs-content^="You have the option to choose one or more of the following terms"]'))
        .to be_present
    end
  end
end
