class CreateCollectionVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_versions do |t|
      t.integer :version, default: 1, null: false
      t.string :state, null: false
      t.string :name, null: false
      t.string :description
      t.references :collection, foreign_key: true
      t.timestamps
    end

    add_reference :collections, :head, foreign_key: {to_table: :collection_versions}

    Collection.all.each do |collection|
      version = CollectionVersion.create(state: collection.state,
        name: collection.name,
        description: collection.description,
        collection: collection,
        version: collection.version)
      collection.update(head: version)
      RelatedLink.where(linkable_type: "Collection", linkable_id: collection.id)
        .update_all(linkable_type: "CollectionVersion", linkable_id: version.id)
      ContactEmail.where(emailable_type: "Collection", emailable_id: collection.id)
        .update_all(emailable_type: "CollectionVersion", emailable_id: version.id)
    end

    remove_column :collections, :version, :integer, default: 1, null: false
    remove_column :collections, :name, :string, null: false
    remove_column :collections, :description, :string, null: false
    remove_column :collections, :state, :string, null: false
  end
end
