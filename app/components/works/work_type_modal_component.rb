# frozen_string_literal: true

module Works
  # Draws a popup for selecting work type and subtype
  class WorkTypeModalComponent < ApplicationComponent
    def initialize(turbo: true, form_authenticity_token: nil, method: :get)
      @turbo = turbo
      @form_authenticity_token = form_authenticity_token
      @method = method
    end

    def types
      WorkType.all
    end

    attr_reader :form_authenticity_token, :method

    def turbo?
      @turbo
    end

    def form_method
      if method == :get
        :get
      else
        :post
      end
    end

    def hidden_method?
      [:get, :post].exclude?(method)
    end
  end
end
