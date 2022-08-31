# frozen_string_literal: true

# Displays a collection on the help modal
class HelpCollectionComponent < ApplicationComponent
  attr_reader :form, :key

  def initialize(form:, key:)
    @form = form
    @key = key
  end

  def label
    I18n.t("#{key}.label", scope: scope)
  end

  def description_key
    "#{key}.description"
  end

  def scope
    'help.collections'
  end
end
