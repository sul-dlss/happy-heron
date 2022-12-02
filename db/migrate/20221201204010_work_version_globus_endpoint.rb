class WorkVersionGlobusEndpoint < ActiveRecord::Migration[7.0]
  def change
    add_column :work_versions, :globus_endpoint, :string
  end
end
