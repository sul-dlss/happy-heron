class CreateRoleTerms < ActiveRecord::Migration[6.0]
  def change
    create_table :role_terms do |t|
      t.string :label, null: false

      t.timestamps
    end
  end
end
