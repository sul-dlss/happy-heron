class NoUploadTypeDefault < ActiveRecord::Migration[7.0]
  def up
    change_column_default(:work_versions, :upload_type, nil)
    change_column_null(:work_versions, :upload_type, true)
  end

  def down
    change_column_default(:work_versions, :upload_type, 'browser')
    change_column_null(:work_versions, :upload_type, false)
  end
end
