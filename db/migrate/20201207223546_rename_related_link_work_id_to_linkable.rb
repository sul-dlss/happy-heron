class RenameRelatedLinkWorkIdToLinkable < ActiveRecord::Migration[6.0]
  def change
    remove_column :related_links, :work_id
    add_reference :related_links, :linkable, polymorphic: true
  end
end
