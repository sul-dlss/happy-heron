# typed: true
# frozen_string_literal: true

# Runs queries and builds the data structure for the summary table.
class StatBuilder
  extend T::Sig

  sig { returns(T::Hash[Collection, Hash]) }
  def self.build_stats
    collections_by_id = Collection.all.index_by(&:id)

    by_state.each_with_object({}) do |(id, val), obj|
      obj[collections_by_id.fetch(id)] = val.merge('total' => total.fetch(id))
    end
  end

  sig { returns(T::Hash[Integer, T::Hash[String, Integer]]) }
  def self.by_state
    Work.all.group(:collection_id, :state).count.each_with_object({}) do |((id, state), count), obj|
      obj[id] ||= {}
      obj[id][state] = count
    end
  end
  private_class_method :by_state

  sig { returns(T::Hash[Integer, Integer]) }
  def self.total
    Work.all.group(:collection_id).count.each_with_object({}) do |(id, count), obj|
      obj[id] = count
    end
  end
  private_class_method :total
end
