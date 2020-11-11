# typed: strict
# frozen_string_literal: true

# Models a citation of a work that is related to the deposited work.
class RelatedWork < ApplicationRecord
  extend T::Sig

  COCINA_HASH_TYPE = T.type_alias { { type: String, note: T::Array[{ type: String, value: String }] } }

  belongs_to :work

  validates :citation, presence: true

  sig { returns(COCINA_HASH_TYPE) }
  def to_cocina_hash
    {
      type: 'related to',
      note: [
        { type: 'preferred citation', value: citation }
      ]
    }
  end
end
