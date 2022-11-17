class AddScheduledShipDateToOrderItemAcknowledgement < ActiveRecord::Migration[7.0]
  def change
    add_column :order_item_acknowledgements, :scheduled_ship_date, :datetime
    add_column :order_item_acknowledgements, :scheduled_delivery_date, :datetime
    add_column :order_item_acknowledgements, :rejection_reason, :integer
  end
end
