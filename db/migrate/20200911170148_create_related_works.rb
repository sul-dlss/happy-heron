class CreateRelatedWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :related_works do |t|
      t.references :work, null: false, foreign_key: true
      t.string :citation, null: false

      t.timestamps
    end
  end
end
