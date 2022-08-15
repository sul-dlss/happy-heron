class AddPublicationDateToWorkVersion < ActiveRecord::Migration[7.0]
  def change
    change_table :work_versions do |t|
      t.datetime :published_at
    end
  end
end
