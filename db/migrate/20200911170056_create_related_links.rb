class CreateRelatedLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :related_links do |t|
      t.references :work, null: false, foreign_key: true
      t.string :link_title
      t.string :url, null: false

      t.timestamps
    end
  end
end
