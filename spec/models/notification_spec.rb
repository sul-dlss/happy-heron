# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  subject(:notification) { build(:notification, user: user) }

  let(:user) { build(:user) }

  it 'belongs to a user' do
    expect(notification.user).to eq(user)
  end

  it 'has text' do
    expect(notification.text).to be_present
  end

  it 'allows null opened_at date' do
    expect(notification.opened_at).to be_nil
  end
end
