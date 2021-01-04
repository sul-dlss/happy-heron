# typed: strict
# frozen_string_literal: true

# Allow `fixture_file_upload` to work in factories
FactoryBot::SyntaxRunner.class_eval do
  include ActiveSupport::Testing::FileFixtures
  include ActionDispatch::TestProcess
end
