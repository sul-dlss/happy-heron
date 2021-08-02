class AddOrcidToAbstractContributors < ActiveRecord::Migration[6.1]
  def change
    add_column :abstract_contributors, :orcid, :string
  end
end
