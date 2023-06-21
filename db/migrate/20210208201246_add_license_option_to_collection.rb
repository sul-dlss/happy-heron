class AddLicenseOptionToCollection < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :license_option, :string
    Collection.all.each do |col|
      col.update(license_option: col.required_license.nil? ? "depositor-selects" : "required")
    end
    change_column_null :collections, :license_option, false
    change_column_default :collections, :license_option, from: nil, to: "required"
  end
end
