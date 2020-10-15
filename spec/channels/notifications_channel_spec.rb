# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsChannel do
  let(:user) { create(:user) }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it 'subscribes successfully' do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("notifications:#{user.id}")
    end
  end

  describe '#unsubscribed' do
    it 'unsubscribes successfully' do
      subscribe

      expect(subscription).to have_stream_from("notifications:#{user.id}")

      perform :unsubscribed
      expect(subscription).not_to have_streams
    end
  end
end
