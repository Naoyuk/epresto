class AddShipWindowFromToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :ship_window_from, :datetime
    add_column :orders, :ship_window_to, :datetime
  end
end
