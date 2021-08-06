# frozen_string_literal: true

# A button that opens a modal containing the citation for a deposit
class CitationComponent < ApplicationComponent
  def initialize(work_version:)
    @work_version = work_version
  end

  def call
    attrs = {
      data: data_attributes, class: 'citation-button'
    }

    attrs[:disabled] = work_version.first_draft? || work_version.purl_reserved?

    tag.button(**attrs) do
      # It's a SafeBuffer, not a String
      tag.span(class: 'fas fa-quote-left') + ' Cite' # rubocop:disable Style/StringConcatenation
    end
  end

  attr_reader :work_version

  private

  def data_attributes
    {
      controller: 'show-citation',
      action: 'show-citation#setContent',
      show_citation_citation_value: work_version.citation,
      show_citation_header_value: work_version.title,
      show_citation_target_value: '#citationModal',
      bs_toggle: 'modal',
      bs_target: '#citationModal'
    }
  end
end
