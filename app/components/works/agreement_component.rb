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

    delegate :owner, to: :work
    delegate :agreed_to_terms_recently?, :last_work_terms_agreement, to: :owner

    attr_reader :form
  end
end
