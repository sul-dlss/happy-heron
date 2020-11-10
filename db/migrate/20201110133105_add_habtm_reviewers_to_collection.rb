class AddHabtmReviewersToCollection < ActiveRecord::Migration[6.0]
  def change
    remove_column :collections, :reviewers, :string

    create_join_table :collections, :users, table_name: :reviewers do |t|
      t.index [:collection_id, :user_id], unique: true
    end
  end
end
