class AddWeightToAbstractContributor < ActiveRecord::Migration[6.1]
  def change
    add_column :abstract_contributors, :weight, :integer
  end
end
