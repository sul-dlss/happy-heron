# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmail, type: :model do
  subject(:contact_email) { build(:contact_email, emailable: work) }

  let(:work) { build(:work) }

  it 'has an email' do
    expect(contact_email.email).to be_present
  end

  it 'has a valid email' do
    contact_email.email = 'asdfasdfe'
    expect { contact_email.save! }.to raise_error(ActiveRecord::RecordInvalid, /Email is invalid/)
  end

  it 'belongs to a work' do
    expect(contact_email.emailable).to eq work
  end
end
