class WorkUploadType < ActiveRecord::Migration[7.0]
  def up
    # new column to store which type of upload mechanism the user wants for their files
    add_column :work_versions, :upload_type, :string, default: "browser", null: false

    # update state of new column based on previous globus true/false column
    WorkVersion.where(globus: true).update_all(upload_type: "globus")
    WorkVersion.where(globus: false).update_all(upload_type: "browser")

    # remove globus column
    remove_column :work_versions, :globus
  end

  def down
    add_column :work_versions, :globus, :boolean, default: false, null: false

    WorkVersion.where(upload_type: "globus").update_all(globus: true)
    WorkVersion.where(upload_type: "browser").update_all(globus: false)

    remove_column :work_versions, :upload_type
  end
end
