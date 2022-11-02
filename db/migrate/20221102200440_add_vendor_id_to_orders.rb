class AddVendorIdToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :vendor, null: false, foreign_key: true
  end
end
