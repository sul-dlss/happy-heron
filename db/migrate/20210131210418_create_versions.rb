class CreateVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :versions do |t|
      t.text :description
      t.references :versionable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
