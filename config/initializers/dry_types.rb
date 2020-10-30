# typed: ignore
# frozen_string_literal: true

# Import dry-types into global Types constant
module Types
  include Dry.Types()

  module Custom
    # For some types, e.g., date component fields in the work form, we want to
    # coerce values to integers UNLESS they are blank strings. Reform uses
    # dry-types to handle type coercion and this is the dry-types way to handle
    # this use case.
    NilableInteger = Types::Params::Integer | Types::Params::Nil
  end
end
