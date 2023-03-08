class RenameVendorColumnToOrders < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :vendor, :vendor_code
  end
end
