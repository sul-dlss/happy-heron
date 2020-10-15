# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkFormComponent do
  let(:component) { described_class.new(work: work) }
  let(:fake_form) do
    instance_double(ActionView::Helpers::FormBuilder,
                    file_field: nil,
                    object: work,
                    label: nil,
                    select: nil,
                    hidden_field: nil,
                    text_field: nil,
                    email_field: nil,
                    text_area: nil,
                    check_box: nil,
                    submit: nil)
  end
  let(:work) { create(:work) }

  before do
    allow(component).to receive(:form_with).and_yield(fake_form)
  end

  it 'renders the component' do
    expect(render_inline(component).to_html)
      .to include('Deposit your work', '1. File', 'Add your files', 'Type of Book deposit',
                  'Title of deposit and contact information', 'Authors and contributors', 'Date content was created',
                  'Describe your deposit', 'Manage release of this item', 'Terms of use and license')
  end
end
