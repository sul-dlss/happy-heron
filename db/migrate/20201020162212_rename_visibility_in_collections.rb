class RenameVisibilityInCollections < ActiveRecord::Migration[6.0]
  def change
    rename_column :collections, :visibility, :access
  end
end
