# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AddFilesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Add your files')
  end
end
