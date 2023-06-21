class AddReviewEnabledToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :review_enabled, :boolean, default: false, null: false
    Collection.joins(:reviewed_by)
      .group("collections.id")
      .having("count(reviewers.user_id) > 1")
      .update_all(review_enabled: true)
  end
end
