class AddShipToIdToOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :shipto, foreign_key: true
  end
end
