class AllowNullFields < ActiveRecord::Migration[6.1]
  def change
    # If the version is a first draft these fields could be nil.
    change_column_null :work_versions, :title, true
    change_column_null :work_versions, :abstract, true
  end
end
