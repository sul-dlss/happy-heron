# typed: true
class CreateContributors < ActiveRecord::Migration[6.0]
  def change
    create_table :contributors do |t|
      t.references :work, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.references :role_term, null: false, foreign_key: true

      t.timestamps
    end
  end
end
