class AddSellingAddressLine1ToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :selling_address_name, :string
    add_column :orders, :selling_address_line1, :string
    add_column :orders, :selling_address_line2, :string
    add_column :orders, :selling_address_line3, :string
    add_column :orders, :selling_address_city, :string
    add_column :orders, :selling_address_district, :string
    add_column :orders, :selling_address_state_or_region, :string
    add_column :orders, :selling_address_postal_code, :string
    add_column :orders, :selling_address_country_code, :string
    add_column :orders, :selling_address_phone, :string
    add_column :orders, :buying_address_line2, :string
    add_column :orders, :buying_address_line3, :string
    add_column :orders, :buying_address_district, :string
    add_column :orders, :ship_to_address_line2, :string
    add_column :orders, :ship_to_address_line3, :string
    add_column :orders, :ship_to_address_district, :string
    add_column :orders, :bill_to_address_line2, :string
    add_column :orders, :bill_to_address_line3, :string
    add_column :orders, :bill_to_address_district, :string
    add_column :orders, :ship_window, :string
  end
end
