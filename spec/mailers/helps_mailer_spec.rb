# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HelpsMailer, type: :mailer do
  describe 'jira_email' do
    let(:mail) do
      described_class.with(name: 'Barbara Seville',
                           email: 'razor@haircuts.it',
                           affiliation: 'Music School',
                           help_how: 'who should marry Rosina?',
                           why_contact: 'Don Basilio! – Cosa veggo!').jira_email
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'who should marry Rosina?'
      expect(mail.to).to eq ['sdr-support@jirasul.stanford.edu']
      expect(mail.from).to eq ['razor@haircuts.it']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include 'Barbara Seville Music School'
      expect(mail.body.encoded).to include 'Don Basilio! – Cosa veggo!'
    end
  end
end
