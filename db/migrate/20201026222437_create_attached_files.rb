class CreateAttachedFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :attached_files do |t|
      t.string :label
      t.boolean :hide, default: false, null: false
      t.references :work, null: false, foreign_key: true

      t.timestamps
    end
  end
end
