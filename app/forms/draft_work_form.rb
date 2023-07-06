# frozen_string_literal: true

require "reform/form/coercion"

# The form for draft work creation and editing
class DraftWorkForm < BaseWorkForm
  has_contributors(validate: false)
end
