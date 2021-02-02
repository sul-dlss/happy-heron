class RenameContributors < ActiveRecord::Migration[6.1]
  def change
    rename_table 'contributors', 'abstract_contributors'
  end
end
