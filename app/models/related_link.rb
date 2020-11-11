# typed: strict
# frozen_string_literal: true

# Models a URI that is related to a work
class RelatedLink < ApplicationRecord
  extend T::Sig

  COCINA_HASH_TYPE_NO_TITLE = T.type_alias { { type: String, access: { url: T::Array[{ value: String }] } } }
  COCINA_HASH_TYPE_WITH_TITLE = T.type_alias do
    { type: String, access: { url: T::Array[{ value: String }] }, title: T::Array[{ value: String }] }
  end
  COCINA_HASH_TYPE = T.type_alias { T.any(COCINA_HASH_TYPE_NO_TITLE, COCINA_HASH_TYPE_WITH_TITLE) }

  belongs_to :work

  validates :url, presence: true

  sig { returns(COCINA_HASH_TYPE) }
  def to_cocina_hash
    {
      type: 'related to',
      access: { url: [{ value: url }] }
    }.tap do |h|
      h[:title] = [{ value: link_title }] if link_title.present?
    end
  end
end
