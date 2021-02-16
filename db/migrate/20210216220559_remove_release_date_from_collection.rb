class RemoveReleaseDateFromCollection < ActiveRecord::Migration[6.1]
  def change
    remove_column :collections, :release_date, :date
  end
end
