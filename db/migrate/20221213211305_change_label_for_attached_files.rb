class ChangeLabelForAttachedFiles < ActiveRecord::Migration[7.0]
  def change
    change_column_default(:attached_files, :label, from: nil, to: "")
  end
end
