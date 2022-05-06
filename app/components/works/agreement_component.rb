# frozen_string_literal: true

module Works
  # Renders the widget that indicates the depositor agrees to the terms of deposit.
  class AgreementComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    def agree_to_terms?
      work_form.agree_to_terms
    end

    def work_form
      form.object
    end

    def work
      work_form.model.fetch(:work)
    end

    delegate :depositor, to: :work
    delegate :last_work_terms_agreement, to: :depositor

    attr_reader :form
  end
end
