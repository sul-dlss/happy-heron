class AddFullNameToContributors < ActiveRecord::Migration[6.0]
  def change
    add_column :contributors, :full_name, :string
    change_column_null :contributors, :first_name, true
    change_column_null :contributors, :last_name, true
  end
end
