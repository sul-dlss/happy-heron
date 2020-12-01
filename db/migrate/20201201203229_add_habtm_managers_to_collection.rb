class AddHabtmManagersToCollection < ActiveRecord::Migration[6.0]
  def change
    remove_column :collections, :managers, :string

    create_join_table :collections, :users, table_name: :managers do |t|
      t.index [:collection_id, :user_id], unique: true
    end
  end
end
