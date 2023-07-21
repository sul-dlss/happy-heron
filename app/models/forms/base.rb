module Forms
  class Base < YAAF::Form
    after_save :destroy_associated_models
    attr_reader :main_models, :related_modes, :associated_forms

    delegate :to_param, :persisted?, to: :main_model

    def initialize(attributes = {})
      super(attributes)

      @models = parent_models + [main_model] + associated_forms
    end

    # Must be implemented by subclasses
    def main_model
      raise NotImplementedError
    end

    # May be implemented by subclasses.
    # Parent models are saved before the main model.
    def parent_models
      []
    end

    # May be implemented by subclasses
    def associated_forms
      []
    end

    def self.reject_all_blank?(params)
      # Unlike ActiveRecord::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC,
      # this is recursive.
      params.all? { |key, value| key == "_destroy" || value.blank? || (value.is_a?(Hash) && value.values.all? { |value_value| reject_all_blank?(value_value) }) }
    end

    def destroy_associated_models
      associated_forms.each do |form|
        form.main_model.destroy if form._destroy == "1"
      end
    end
  end
end
