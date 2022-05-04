# frozen_string_literal: true

module Works
  # Renders the widget that indicates the depositor agrees to the terms of deposit.
  class AgreementComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    def agree_to_terms?
      form.object.agree_to_terms
    end

    def date_last_agreed
      form.object.date_last_agreed
    end

    attr_reader :form
  end
end
