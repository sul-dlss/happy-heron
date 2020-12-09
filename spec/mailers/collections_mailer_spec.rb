# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMailer, type: :mailer do
  describe 'invitation_to_deposit_email' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user: user, collection: collection).invitation_to_deposit_email }
    let(:collection) { create(:collection, :with_depositors) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection.name} collection in the SDR"
      expect(mail.to).to eq [collection.depositors.first.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection.name} collection")
    end
  end
end
