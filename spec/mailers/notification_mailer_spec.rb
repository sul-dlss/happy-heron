# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe 'reject_email' do
    let(:user) { work.depositor }
    let(:mail) { described_class.with(user: user, work: work).reject_email }
    let(:work) { build_stubbed(:work, :rejected) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and returned'
      expect(mail.to).to eq [work.depositor.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match('Add something to make it pop.')
    end
  end
end
