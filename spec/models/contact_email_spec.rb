# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmail do
  subject(:contact_email) { build(:contact_email, emailable: work) }

  let(:work) { build(:work) }

  it 'has an email' do
    expect(contact_email.email).to be_present
  end

  it 'belongs to a work' do
    expect(contact_email.emailable).to eq work
  end

  context 'when select attributes contain leading/trailing whitespace' do
    let(:contact_email) do
      create(:contact_email, email: ' timbl@w3.org ', emailable: work)
    end

    it('strips email') do
      expect(contact_email.email).to eq('timbl@w3.org')
    end
  end
end
