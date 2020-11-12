# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AddFilesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.to_html).to include('Add your files')
    expect(rendered.css('button.dz-clickable').to_html).to include('Choose files')
  end
end
