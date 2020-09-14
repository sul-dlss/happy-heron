class CreateWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :works do |t|
      t.string :druid
      t.integer :version
      t.string :title, null: false
      t.string :work_type, null: false
      t.string :subtype, null: false
      t.string :contact_email, null: false
      t.string :created_etdf, null: false
      t.text :abstract, null: false
      t.string :citation, null: false
      t.string :access, null: false
      t.date :embargo_date
      t.string :license, null: false
      t.boolean :agree_to_terms, default: false
      t.timestamps
    end

    add_index :works, [:druid, :version], unique: true
  end
end
