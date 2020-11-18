# typed: false
# frozen_string_literal: true

require 'reform/form/coercion'

# The form for contacting SUL
class HelpForm < Reform::Form
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :help_how, :why_contact, presence: true
end
