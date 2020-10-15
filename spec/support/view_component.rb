# typed: strict
# frozen_string_literal: true

require 'view_component/test_helpers'

RSpec.configure do |config|
  # Make `config.infer_spec_type_from_file_location!` aware of ViewComponent specs
  config.define_derived_metadata(file_path: %r{/spec/components/}) do |metadata|
    metadata[:type] = :component
  end

  config.include ViewComponent::TestHelpers, type: :component
end
