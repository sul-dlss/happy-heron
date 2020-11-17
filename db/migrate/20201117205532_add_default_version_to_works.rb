class AddDefaultVersionToWorks < ActiveRecord::Migration[6.0]
  def change
    change_column_default :works, :version, 0
  end
end
