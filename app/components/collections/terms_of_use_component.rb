# frozen_string_literal: true

module Collections
  # Renders the terms of use section of the collection (show page)
  class TermsOfUseComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :allow_custom_rights_statement?, :custom_rights_statement_source_option,
             :default_license, :effective_custom_rights_instructions, :provided_custom_rights_statement,
             :required_license, :user_can_set_license?, to: :collection

    def collection_custom_rights_summary
      return 'No' unless allow_custom_rights_statement?

      if custom_rights_statement_source_option == 'provided_by_collection'
        provided_custom_rights_statement
      else
        'Allow user to enter'
      end
    end
  end
end
