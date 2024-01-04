# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordEmbargoReleaseJob do
  subject(:run) { described_class.new.work(message) }

  let(:work) { create(:work, :with_druid) }
  let(:message) { { model: }.to_json }
  let(:model) do
    Cocina::Models::DRO.new(externalIdentifier: work.druid,
                            type: Cocina::Models::ObjectType.object,
                            label: 'my repository object',
                            version: 1,
                            description: {
                              title: [{ value: 'my repository object' }],
                              purl: "https://purl.stanford.edu/#{work.druid.delete_prefix('druid:')}"
                            },
                            access: {},
                            administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                            identification: {
                              sourceId: "hydrus:object-#{work.id}"
                            },
                            structural: {
                              contains: []
                            })
  end

  it 'stores an event for the work' do
    expect { run }.to change { work.events.count }.by(1)
  end
end
