class CollectionValuesOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null :collections, :access, true
    change_column_null :collections, :contact_email, true
    change_column_null :collections, :description, true
  end
end
