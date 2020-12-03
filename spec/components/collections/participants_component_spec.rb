# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::ParticipantsComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collection' do
    let(:depositors) { collection.depositors.pluck(:email).join(', ') }
    let(:managers) { collection.managers.pluck(:email).join(', ') }
    let(:collection) { build_stubbed(:collection, :with_managers, :with_depositors) }

    it 'renders the participant component' do
      expect(rendered.css('table').to_html).to include(managers)
      expect(rendered.css('table').to_html).to include(depositors)
    end
  end
end
