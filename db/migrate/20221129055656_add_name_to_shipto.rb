class AddNameToShipto < ActiveRecord::Migration[7.0]
  def change
    rename_column :shiptos, :airport_code, :location_code
    add_column :shiptos, :customer_name, :string
    add_column :shiptos, :address_line1, :string
    add_column :shiptos, :address_line2, :string
    add_column :shiptos, :city, :string
    add_column :shiptos, :postal_code, :string
    add_column :shiptos, :contact_name1, :string
    add_column :shiptos, :email1, :string
    add_column :shiptos, :phone1, :string
    add_column :shiptos, :contact_name2, :string
    add_column :shiptos, :email2, :string
    add_column :shiptos, :phone2, :string
    add_column :shiptos, :send_report, :boolean
    add_column :shiptos, :visu_email, :boolean
  end
end
