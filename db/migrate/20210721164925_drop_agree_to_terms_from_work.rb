class DropAgreeToTermsFromWork < ActiveRecord::Migration[6.1]
  def change
    remove_column :work_versions, :agree_to_terms, :boolean
  end
end
