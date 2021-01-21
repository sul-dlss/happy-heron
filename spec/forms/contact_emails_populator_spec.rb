# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmailsPopulator do
  subject(:contact_email_populator) { described_class.new(work_form, ContactEmail) }

  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }

  it 'renders a contact email row' do
    keep_fragment = ActionController::Parameters.new({ '_destroy': 'false', 'email': 'test@local.edu' })
    expect(contact_email_populator.call(work_form,
                                        fragment: keep_fragment)).to be_truthy
  end

  it 'removes a contact email row' do
    remove_keep = ActionController::Parameters.new({ '_destroy': '1', 'email': 'test@local.edu' })
    expect(contact_email_populator.call(work_form,
                                        fragment: remove_keep)).to eq Representable::Pipeline::Stop
  end
end
