# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::VersionDescriptionComponent do
  let(:form) do
    instance_double(ActionView::Helpers::FormBuilder,
                    label: nil,
                    text_field: nil,
                    fields_for: nil)
  end

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Version your work')
  end
end
