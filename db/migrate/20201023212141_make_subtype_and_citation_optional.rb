class MakeSubtypeAndCitationOptional < ActiveRecord::Migration[6.0]
  def change
    remove_column :works, :subtype
    add_column :works, :subtype, :text, array: true, default: []
    # change_column_null :works, :subtype, true
    change_column_null :works, :citation, true
  end
end
