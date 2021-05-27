class AddVersionDescriptionToCollectionVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :collection_versions, :version_description, :string
  end
end
