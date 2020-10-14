# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddFilesComponent do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder, file_field: nil) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Add your files')
  end
end
