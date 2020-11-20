class AddVersionAndDruidToCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :collections, :druid, :string, null: true
    add_column :collections, :version, :integer, null: false, default: 0
    add_index :collections, :druid, unique: true
  end
end
