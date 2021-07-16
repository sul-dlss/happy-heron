class ChangeAddDoiDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :works, :assign_doi, true
  end
end
