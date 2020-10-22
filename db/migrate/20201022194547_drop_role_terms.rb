class DropRoleTerms < ActiveRecord::Migration[6.0]
  def change
    remove_column :contributors, :role_term_id
    add_column :contributors, :contributor_type, :string, null: false
    add_column :contributors, :role, :string, null: false

    drop_table :role_terms
  end
end
