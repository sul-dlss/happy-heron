# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkUpdatesChannel do
  let(:user) { create(:user) }
  let(:work) { create(:work) }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it 'subscribes successfully' do
      subscribe(workId: work.id)

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("work_updates:#{work.to_gid_param}")
    end
  end

  describe '#unsubscribed' do
    it 'unsubscribes successfully' do
      subscribe(workId: work.id)

      expect(subscription).to have_stream_from("work_updates:#{work.to_gid_param}")

      perform :unsubscribed
      expect(subscription).not_to have_streams
    end
  end
end
