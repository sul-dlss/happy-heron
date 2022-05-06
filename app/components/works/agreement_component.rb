# frozen_string_literal: true

module Works
  # Renders the widget that indicates the depositor agrees to the terms of deposit.
  class AgreementComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    def work_form
      form.object
    end

    def work
      work_form.model.fetch(:work)
    end

    delegate :depositor, to: :work
    delegate :agreed_to_terms_recently?, :last_work_terms_agreement, to: :depositor

    attr_reader :form
  end
end
