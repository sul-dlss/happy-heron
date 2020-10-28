class CreateKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :keywords do |t|
      t.references :work, null: false, foreign_key: true
      t.string :label
      t.string :uri

      t.timestamps
    end
  end
end
