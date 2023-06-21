class UpdateDefaultCollectionState < ActiveRecord::Migration[6.0]
  def change
    change_column_default :collections, :state, "new"
  end
end
