# typed: strict
# frozen_string_literal: true

# Runs queries and builds the data structure for the summary table.
class StatBuilder
  extend T::Sig

  sig { returns(T::Hash[Collection, T::Hash[String, Integer]]) }
  def self.build_stats
    works = Work.all.group(:collection_id, :state).count

    # We only use a few fields from the collection, so don't waste time
    # pulling back the other attributes.
    Collection.select(:id, :name, :updated_at).index_with do |collection|
      works
        # filter works to those that belong to the collection in the current iteration of the block
        .select { |(collection_id, _state), _count| collection_id == collection.id }
        # change keys via `#group` above from `[80, "rejected"]=>1` to `"rejected"=>1`
        .transform_keys { |(_collection_id, state)| state }
        # inject totals into hash
        .tap { |counts| counts['total'] = counts.values.sum }
    end
  end
end
