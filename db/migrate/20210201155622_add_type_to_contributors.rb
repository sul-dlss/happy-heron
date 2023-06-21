class AddTypeToContributors < ActiveRecord::Migration[6.1]
  def change
    add_column :contributors, :type, :string, default: "Author"
    change_column_default :contributors, :type, to: nil, from: :string
  end
end
