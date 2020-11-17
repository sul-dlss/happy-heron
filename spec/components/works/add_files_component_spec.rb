# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AddFilesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }
  let(:work_form) { WorkForm.new(object) }

  context 'with an unpersisted file component' do
    let(:object) { build(:work) }

    it 'renders the component' do
      expect(rendered.to_html).to include('Add your files')
      expect(rendered.css('button.dz-clickable').to_html).to include('Choose files')
    end
  end

  context 'with a persisted file component' do
    let(:attached_file) { create(:attached_file, :with_file) }
    let(:object) { build(:work, attached_files: [attached_file]) }

    it 'renders the component with the filename visible' do
      expect(rendered.to_html).to include('Add your files')
      expect(rendered.to_html).to include(attached_file.filename.to_s)
      expect(rendered.css('button.dz-clickable').to_html).to include('Choose files')
    end
  end
end
