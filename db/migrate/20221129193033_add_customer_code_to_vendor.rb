class AddCustomerCodeToVendor < ActiveRecord::Migration[7.0]
  def change
    add_column :vendors, :customer_code, :string
  end
end
