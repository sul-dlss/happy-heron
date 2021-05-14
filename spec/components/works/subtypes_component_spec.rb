# typed: false
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
      expect(rendered.to_html).to include('Work types *')
    end
  end

  context 'when work type is "music"' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'music', subtype: ['Data']) }

    it 'does not label subtypes as optional' do
      expect(rendered.to_html).to include('Work types *')
    end

    it 'renders a header about selecting one or more terms' do
      expect(rendered.to_html).to include('Select at least one term below')
    end
  end

  context 'when work type is "mixed material"' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'mixed material', subtype: %w[Data Sound]) }

    it 'does not label subtypes as optional' do
      expect(rendered.to_html).to include('Work types *')
    end

    it 'renders a header about selecting two or more terms' do
      expect(rendered.to_html).to include('Select at least two terms below')
    end
  end

  context 'when work type is anything else' do
    it 'does not label subtypes as required' do
      expect(rendered.to_html).to include('Work types')
    end
  end
end
