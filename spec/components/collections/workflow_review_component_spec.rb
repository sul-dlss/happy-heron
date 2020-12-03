# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::WorkflowReviewComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collection' do
    let(:reviewers) { collection.reviewers.pluck(:email).join(', ') }
    let(:collection) { build_stubbed(:collection, :with_reviewers) }

    it 'renders the workflow review component' do
      expect(rendered.css('table').to_html).to include('On')
      expect(rendered.css('table').to_html).to include(reviewers)
    end
  end
end
