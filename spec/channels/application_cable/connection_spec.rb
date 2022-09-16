# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection do
  let(:env) { { 'warden' => warden } }
  let(:mount_path) { Rails.application.config.action_cable.mount_path }
  let(:warden) { instance_double(Warden::Proxy, user:) }

  before do
    allow_any_instance_of(described_class).to receive(:env).and_return(env)
  end

  context 'with an active session' do
    let(:user) { create(:user) }

    it 'makes a connection' do
      connect mount_path
      expect(connection.current_user).to eq user
    end
  end

  context 'without an active session' do
    let(:user) { nil }

    it 'rejects the connection' do
      expect { connect mount_path }.to have_rejected_connection
    end
  end
end
