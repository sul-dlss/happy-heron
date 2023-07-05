class CreateAffiliations < ActiveRecord::Migration[7.0]
  def change
    create_table :affiliations do |t|
      t.references :abstract_contributor, null: false, foreign_key: true
      t.string :label
      t.string :uri
      t.string :department

      t.timestamps
    end
  end
end
